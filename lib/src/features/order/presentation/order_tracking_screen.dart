import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropx_mobile/src/common_widgets/app_google_map.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/features/order/providers/order_providers.dart';
import 'package:dropx_mobile/src/features/order/data/dto/order_tracking_live_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/delivery_otp_response.dart';
import 'package:dropx_mobile/src/features/order/data/dto/cancel_order_request.dart';
import 'package:dropx_mobile/src/features/order/data/dto/cancel_reason_code.dart';
import 'package:dropx_mobile/src/features/order/data/dto/dispute_order_request.dart';
import 'package:dropx_mobile/src/features/order/data/dto/dispute_reason_code.dart';
import 'package:dropx_mobile/src/features/order/data/dto/submit_review_request.dart';
import 'package:dropx_mobile/src/features/order/data/dto/get_my_review_response.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:dropx_mobile/src/core/services/app_notifications.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/utils/direction_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dropx_mobile/src/core/utils/cloudinary_upload.dart';

// ─── Cancellable order states ───────────────────────────────────────────────
const _cancelAllowedStates = {
  'PAYMENT_PENDING',
  'PLACED',
  'ACCEPTED',
  'ARRIVED_PICKUP',
};

// ─── Disputable order states ─────────────────────────────────────────────────
// Also allow DISPUTED so users can add further evidence
const _disputeAllowedStates = {'DELIVERED', 'CANCELLED', 'DISPUTED'};

// ─── Terminal states (no further actions possible) ───────────────────────────
const _terminalStates = {'COMPLETED'};

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String? orderId;

  const OrderTrackingScreen({super.key, this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen>
    with TickerProviderStateMixin {
  // UI stage index: 0=Placed, 1=Accepted/Picked up, 2=In Transit, 3=Delivered, 4=Completed
  int _orderStage = 0;
  String _status = 'Order Placed';
  Color _statusColor = Colors.grey;

  // The last state string passed to _applyState — used as the authoritative
  // source for action visibility so it stays in sync even when _liveData is null.
  String _rawState = 'PLACED';

  // Whether we are still waiting for the very first data fetch
  bool _isLoading = false;

  // True when the last tracking call returned TRACKING_STALE (503)
  bool _locationIsStale = false;

  // Live data
  OrderTrackingLiveData? _liveData;

  // Delivery OTP (fetched from dedicated endpoint when rider is in transit)
  DeliveryOtpData? _deliveryOtpData;

  bool _isConfirmingDelivery = false;
  bool _deliveryConfirmed = false;

  GoogleMapController? _mapController;
  StreamSubscription<SseEvent>? _sseSub;

  // The rider position actually rendered on the map — animates smoothly
  // toward each new fix instead of snapping, so the pin visibly glides
  // rather than looking static while the camera pans around it.
  LatLng? _displayedRiderLatLng;
  AnimationController? _riderAnimController;
  LatLng? _riderAnimFrom;
  LatLng? _riderAnimTo;

  // Tracks which state we last fired a local notification for, to avoid duplicates on SSE reconnect.
  String? _notifiedState;

  // Set locally after a successful submit in this session — the customer
  // never needs their own past review re-fetched/shown, so this is not
  // checked against the server on load.
  ReviewData? _existingReview;

  // Route polyline drawn from rider → customer delivery address.
  Set<Polyline> _polylines = {};
  bool _routeLoading = false;
  // Last rider LatLng for which we fetched a route — avoids redundant API calls.
  LatLng? _lastRouteOrigin;

  @override
  void initState() {
    super.initState();
    // Apply the initial state immediately so the screen never shows
    // a stale/blank "Preparing..." on first render.
    _applyState('PLACED');
    debugPrint(
      '📍 [TRACKING] initState orderId=${widget.orderId ?? "null (simulation)"}',
    );
    _fetchLiveTracking();
    _subscribeToSse();
  }

  void _subscribeToSse() {
    if (widget.orderId == null || !mounted) return;
    _sseSub?.cancel();
    final client = ref.read(apiClientProvider);
    _sseSub = client
        .sseStream(ApiEndpoints.sseOrder(widget.orderId!))
        .listen(
          _onSseEvent,
          onDone: () => Future.delayed(
            const Duration(seconds: 3),
            () { if (mounted) _subscribeToSse(); },
          ),
          onError: (_) => Future.delayed(
            const Duration(seconds: 5),
            () { if (mounted) _subscribeToSse(); },
          ),
        );
  }

  void _onSseEvent(SseEvent event) {
    debugPrint('📡 [SSE] type=${event.type} data=${event.data}');
    if (!mounted) return;
    if (event.data.isEmpty) return;

    // Heartbeat — use as a silent poll to catch any missed state_change events.
    if (event.type == 'heartbeat') {
      _fetchLiveTrackingSilent();
      return;
    }

    // Accept state_change events
    if (event.type != 'state_change') return;

    try {
      final json = jsonDecode(event.data) as Map<String, dynamic>;
      final newState = json['state'] as String?;

      debugPrint('📡 [SSE] state_change → $newState');

      if (newState == null) return;

      // Apply the state immediately from the SSE payload
      // Don't try to parse a full OrderTrackingLiveData from this minimal payload
      setState(() => _applyState(newState));
      _maybeNotify(newState);

      // Then fetch full tracking data to get rider info, ETA, location etc —
      // unless that state transition just stopped tracking entirely.
      if (_sseSub != null) {
        _fetchLiveTrackingSilent();
      }

      if (newState == 'IN_TRANSIT' ||
          newState == 'PICKED_UP' ||
          newState == 'ARRIVED_DROPOFF') {
        _fetchDeliveryOtp();
      }
    } catch (e) {
      debugPrint('📡 [SSE] parse error: $e');
    }
  }
  Future<void> _fetchLiveTrackingSilent() async {
    if (widget.orderId == null) return;
    try {
      final repo = ref.read(orderRepositoryProvider);
      final response = await repo.trackOrderLive(widget.orderId!);
      if (mounted) {
        setState(() {
          _liveData = response.data;
          _locationIsStale = response.data.isStale ?? false;
          _applyState(_liveData?.state ?? 'PLACED');
        });
        if (_liveData?.location != null && _mapController != null) {
          final newPos = LatLng(_liveData!.location!.lat, _liveData!.location!.lng);
          _mapController!.animateCamera(CameraUpdate.newLatLng(newPos));
          _moveRiderMarker(newPos);
        }
        _maybeRefreshRoute();
        final state = _liveData?.state ?? '';
        if (state == 'IN_TRANSIT' ||
            state == 'PICKED_UP' ||
            state == 'ARRIVED_DROPOFF') {
          _fetchDeliveryOtp();
        }
      }
    } catch (e) {
      if (e is ApiException && (e.statusCode == 409 || e.statusCode == 503)) {
        final errorBody = e.data as Map<String, dynamic>?;
        final details = errorBody?['error']?['details'] as Map<String, dynamic>?;
        final stateFromError = details?['state'] as String?;
        if (mounted && stateFromError != null) {
          setState(() {
            _applyState(stateFromError);
            _locationIsStale = e.statusCode == 503;
          });
        }
      }
      // Silent — no spinner, no snackbar
    }
  }
  Future<void> _fetchLiveTracking() async {
    if (widget.orderId == null) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(orderRepositoryProvider);
      final response = await repo.trackOrderLive(widget.orderId!);
      if (mounted) {
        setState(() {
          _liveData = response.data;
          _locationIsStale = response.data.isStale ?? false;
          _applyState(_liveData?.state ?? 'PLACED');
        });
        if (_liveData?.location != null && _mapController != null) {
          final newPos = LatLng(_liveData!.location!.lat, _liveData!.location!.lng);
          _mapController!.animateCamera(CameraUpdate.newLatLng(newPos));
          _moveRiderMarker(newPos);
        }
        _maybeRefreshRoute();
        // Fetch OTP from dedicated endpoint when rider is in transit or arrived
        final state = _liveData?.state ?? '';
        if (state == 'IN_TRANSIT' ||
            state == 'PICKED_UP' ||
            state == 'ARRIVED_DROPOFF') {
          _fetchDeliveryOtp();
        }
      }
    } catch (e) {
      // 409 (TRACKING_NOT_AVAILABLE / RIDER_NOT_ASSIGNED) and
      // 503 (TRACKING_STALE) both carry the real order state in
      // error.details.state — extract and apply it so the UI always
      // reflects the correct status even when live tracking is unavailable.
      if (e is ApiException &&
          (e.statusCode == 409 || e.statusCode == 503)) {
        final errorBody = e.data as Map<String, dynamic>?;
        final details =
            errorBody?['error']?['details'] as Map<String, dynamic>?;
        final stateFromError = details?['state'] as String?;

        debugPrint(
          '⚠️ [TRACKING] ${e.statusCode} — state=$stateFromError (${e.message})',
        );

        if (mounted) {
          setState(() {
            if (stateFromError != null) _applyState(stateFromError);
            _locationIsStale = e.statusCode == 503;
          });

          // For in-transit states fetched from the error path, still
          // attempt to load the delivery OTP.
          if (stateFromError == 'IN_TRANSIT' ||
              stateFromError == 'PICKED_UP' ||
              stateFromError == 'ARRIVED_DROPOFF') {
            _fetchDeliveryOtp();
          }
        }
      } else {
        debugPrint('❌ [TRACKING] Unexpected tracking error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchDeliveryOtp() async {
    if (widget.orderId == null) return;
    try {
      final repo = ref.read(orderRepositoryProvider);
      final data = await repo.getDeliveryOtp(widget.orderId!);
      if (mounted && data != null && data.deliveryOtpAvailable) {
        setState(() => _deliveryOtpData = data);
      }
    } catch (e) {
      debugPrint('❌ [TRACKING] getDeliveryOtp failed: $e');
    }
  }

  // ─── Route / directions ─────────────────────────────────────────────────

  /// Call after any update that may have changed the rider's position.
  /// Skips re-fetching if the rider hasn't moved more than ~30 m.
  void _maybeRefreshRoute() {
    if (_liveData?.location == null) return;
    if (_orderStage >= 3) {
      // Delivered/completed — remove the route line.
      if (_polylines.isNotEmpty) setState(() => _polylines = {});
      return;
    }

    final riderLatLng = LatLng(
      _liveData!.location!.lat,
      _liveData!.location!.lng,
    );

    if (_lastRouteOrigin != null) {
      final dlat = (riderLatLng.latitude - _lastRouteOrigin!.latitude).abs();
      final dlng = (riderLatLng.longitude - _lastRouteOrigin!.longitude).abs();
      // ~0.0003° ≈ 33 m — skip if rider hasn't moved meaningfully
      if (dlat < 0.0003 && dlng < 0.0003) return;
    }

    final session = ref.read(sessionServiceProvider);
    final userLatLng = LatLng(session.savedLat, session.savedLng);
    _fetchRoutePolyline(riderLatLng: riderLatLng, userLatLng: userLatLng);
  }

  Future<void> _fetchRoutePolyline({
    required LatLng riderLatLng,
    required LatLng userLatLng,
  }) async {
    _lastRouteOrigin = riderLatLng;
    if (mounted) setState(() => _routeLoading = true);
    try {
      final routePoints = await DirectionsHelper.getRoutePoints(
        origin: riderLatLng,
        destination: userLatLng,
      );
      if (!mounted) return;
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('delivery_route'),
            points: routePoints.isNotEmpty
                ? routePoints
                : [riderLatLng, userLatLng],
            color: AppColors.primaryOrange,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        };
      });
      _fitCamera([riderLatLng, userLatLng]);
    } catch (e) {
      debugPrint('❌ [TRACKING] Route build failed: $e');
    } finally {
      if (mounted) setState(() => _routeLoading = false);
    }
  }

  void _fitCamera(List<LatLng> points) {
    if (_mapController == null || points.length < 2) return;
    final lats = points.map((p) => p.latitude);
    final lngs = points.map((p) => p.longitude);
    const pad = 0.008;
    final bounds = LatLngBounds(
      southwest: LatLng(
        lats.reduce((a, b) => a < b ? a : b) - pad,
        lngs.reduce((a, b) => a < b ? a : b) - pad,
      ),
      northeast: LatLng(
        lats.reduce((a, b) => a > b ? a : b) + pad,
        lngs.reduce((a, b) => a > b ? a : b) + pad,
      ),
    );
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 72));
  }

  /// The delivery OTP, from the dedicated endpoint — live-summary only
  /// carries availability metadata, never the raw code. Returns null when
  /// no OTP is available yet.
  String? get _resolvedOtp => _deliveryOtpData?.deliveryOtp;

  void _maybeNotify(String newState) {
    debugPrint('🔔 [Tracking] _maybeNotify — newState=$newState _notifiedState=$_notifiedState');
    if (newState == _notifiedState) {
      debugPrint('🔔 [Tracking] _maybeNotify — skipped (already notified for $newState)');
      return;
    }
    _notifiedState = newState;
    AppNotifications.orderStateChanged(newState, widget.orderId ?? '');
  }

  /// Map API state string → local stage + labels.
  void _applyState(String state) {
    _rawState = state;
    switch (state) {
      case 'PAYMENT_PENDING':
        _orderStage = 0;
        _status = 'Payment Pending';
        _statusColor = Colors.orange;
      case 'PLACED':
        _orderStage = 0;
        _status = 'Order Placed';
        _statusColor = Colors.grey;
      case 'VENDOR_ACCEPTED':
        _orderStage = 0;
        _status = 'Vendor Accepted';
        _statusColor = Colors.blue;
      case 'READY_FOR_PICKUP':
        _orderStage = 1;
        _status = 'Ready for Pickup';
        _statusColor = Colors.blue;
      case 'ACCEPTED':
        _orderStage = 1;
        _status = 'Order Accepted';
        _statusColor = AppColors.primaryOrange;
      case 'ARRIVED_PICKUP':
        _orderStage = 1;
        _status = 'Rider at Pickup';
        _statusColor = Colors.blue;
      case 'PICKED_UP':
      case 'IN_TRANSIT':
        _orderStage = 2;
        _status = 'On the Way';
        _statusColor = AppColors.primaryOrange;
      case 'ARRIVED_DROPOFF':
        _orderStage = 2;
        _status = 'Rider Arrived';
        _statusColor = AppColors.primaryOrange;
      case 'DELIVERED':
        _orderStage = 3;
        _status = 'Delivered';
        _statusColor = Colors.green;
        _stopLiveTracking();
      case 'COMPLETED':
        _orderStage = 4;
        _status = 'Completed';
        _statusColor = Colors.green;
        _stopLiveTracking();
        ref.read(sessionServiceProvider).clearLastRoute();
      case 'CANCELLED':
        _orderStage = 0;
        _status = 'Cancelled';
        _statusColor = Colors.red;
        _stopLiveTracking();
        ref.read(sessionServiceProvider).clearLastRoute();
      case 'DISPUTED':
        _orderStage = 0;
        _status = 'Disputed';
        _statusColor = Colors.red;
        _stopLiveTracking();
      default:
        _orderStage = 1;
        _status = 'On the Way';
        _statusColor = AppColors.primaryOrange;
    }
  }

  /// Once the order is delivered/completed/cancelled/disputed there's no
  /// rider left to track — stop polling and drop the SSE subscription
  /// instead of continuing to fetch and animate a rider position that no
  /// longer means anything to the customer.
  void _stopLiveTracking() {
    _sseSub?.cancel();
    _sseSub = null;
    _riderAnimController?.stop();
  }

  @override
  void dispose() {
    _sseSub?.cancel();
    _mapController?.dispose();
    _riderAnimController?.dispose();
    super.dispose();
  }

  /// Smoothly animates the rendered rider marker from its last position to
  /// [newPos], instead of the marker snapping instantly while only the
  /// camera pans — so the customer can actually see the rider moving.
  void _moveRiderMarker(LatLng newPos) {
    debugPrint(
      '🐎 [MARKER] moveRiderMarker called → newPos=(${newPos.latitude}, ${newPos.longitude}) '
      'current=(${_displayedRiderLatLng?.latitude}, ${_displayedRiderLatLng?.longitude})',
    );
    final from = _displayedRiderLatLng;
    if (from == null) {
      debugPrint('🐎 [MARKER] first fix — setting directly, no animation');
      setState(() => _displayedRiderLatLng = newPos);
      _revealRiderLabel();
      return;
    }
    if (from.latitude == newPos.latitude && from.longitude == newPos.longitude) {
      debugPrint('🐎 [MARKER] position unchanged — skipping animation');
      return;
    }

    debugPrint(
      '🐎 [MARKER] animating (${from.latitude}, ${from.longitude}) → '
      '(${newPos.latitude}, ${newPos.longitude})',
    );
    _riderAnimController?.dispose();
    _riderAnimFrom = from;
    _riderAnimTo = newPos;
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _riderAnimController = controller;
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    curved.addListener(() {
      if (!mounted) return;
      final t = curved.value;
      final lat = _riderAnimFrom!.latitude +
          (_riderAnimTo!.latitude - _riderAnimFrom!.latitude) * t;
      final lng = _riderAnimFrom!.longitude +
          (_riderAnimTo!.longitude - _riderAnimFrom!.longitude) * t;
      debugPrint('🐎 [MARKER] tick t=${t.toStringAsFixed(2)} → ($lat, $lng)');
      setState(() => _displayedRiderLatLng = LatLng(lat, lng));
    });
    controller.forward().whenComplete(() {
      debugPrint(
        '🐎 [MARKER] animation complete → displayed=(${_displayedRiderLatLng?.latitude}, ${_displayedRiderLatLng?.longitude})',
      );
      _revealRiderLabel();
    });
  }

  /// Pops the "Rider" label open after each position update so the customer
  /// notices the marker just moved, without requiring a tap.
  void _revealRiderLabel() {
    if (_mapController == null) return;
    Future.delayed(const Duration(milliseconds: 200), () {
      _mapController?.showMarkerInfoWindow(const MarkerId('rider'));
    });
  }

  // ─── Delivery OTP card ───────────────────────────────────────────────────

  Future<void> _confirmDelivery() async {
    final otp = _resolvedOtp;
    if (otp == null || widget.orderId == null || _isConfirmingDelivery) {
      return;
    }

    setState(() => _isConfirmingDelivery = true);
    try {
      final repo = ref.read(orderRepositoryProvider);
      final result = await repo.verifyDeliveryOtp(widget.orderId!, otp);
      if (!mounted) return;
      setState(() => _deliveryConfirmed = true);
      AppToast.showSuccess(
        context,
        'Delivery confirmed! State: ${result.state}',
      );
    } on ApiException catch (e) {
      if (mounted) AppToast.showError(context, e.message);
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Could not confirm delivery. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isConfirmingDelivery = false);
    }
  }

  Widget _buildDeliveryOtpCard() {
    final otp = _resolvedOtp!;
    final arrived = _currentState == 'ARRIVED_DROPOFF';
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: arrived ? Colors.green.shade200 : AppColors.primaryOrange.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color: arrived ? Colors.green.shade50 : Colors.orange.shade50,
      ),
      child: Column(
        children: [
          AppText(
            arrived ? 'Rider has Arrived — Share your code' : 'Your Delivery Code',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: arrived ? Colors.green.shade700 : AppColors.primaryOrange,
          ),
          const SizedBox(height: 4),
          AppText(
            arrived
                ? 'Verify your order before giving this code to the rider.'
                : 'Have this code ready to give to the rider on arrival.',
            fontSize: 11,
            color: Colors.grey.shade600,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // OTP digits display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: AppText(
              otp.split('').join('  '),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: otp));
                  AppToast.showSuccess(context, 'Code copied!');
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const AppText('Copy', fontSize: 13),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
          if (arrived) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isConfirmingDelivery || _deliveryConfirmed)
                    ? null
                    : _confirmDelivery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isConfirmingDelivery
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : AppText(
                        _deliveryConfirmed
                            ? 'Delivery Confirmed'
                            : 'Confirm Delivery',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Cancel / Dispute state helpers ─────────────────────────────────────

  /// The current authoritative state string — always in sync with _applyState.
  String get _currentState => _rawState;

  /// A short caption breaking the total ETA into vendor prep time vs actual
  /// delivery time, shown only while the vendor is still preparing —
  /// otherwise the raw ETA reads as one opaque number and customers assume
  /// it's all delivery time, which reads as unusually slow.
  String? get _prepTimeBreakdown {
    if (_orderStage >= 2) return null; // already picked up — prep is done
    final prepMinutes = _liveData?.vendorHandoff?.prepEtaMinutes;
    if (prepMinutes == null || prepMinutes <= 0) return null;

    final totalMinutes = _liveData?.etaMinutes;
    if (totalMinutes == null) {
      return 'Includes ~$prepMinutes min for the vendor to prepare your order';
    }
    final deliveryMinutes = (totalMinutes - prepMinutes).clamp(0, totalMinutes);
    return '~$prepMinutes min prep, then ~$deliveryMinutes min delivery';
  }

  bool get _canCancel => _cancelAllowedStates.contains(_currentState);

  bool get _canDispute => _disputeAllowedStates.contains(_currentState);

  bool get _isTerminal => _terminalStates.contains(_currentState);

  /// True when the order is mid-fulfillment and neither action is available.
  bool get _actionsLocked =>
      !_canCancel &&
      !_canDispute &&
      !_isTerminal &&
      _currentState != 'CANCELLED' &&
      _currentState != 'DISPUTED';

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionServiceProvider);
    final userLatLng = LatLng(session.savedLat, session.savedLng);

    final riderLatLng = (_liveData?.location != null)
        ? LatLng(_liveData!.location!.lat, _liveData!.location!.lng)
        : null;

    final displayAddress = session.savedAddress;
    debugPrint(
      '🐎 [MARKER] build → rider marker position=(${(_displayedRiderLatLng ?? riderLatLng)?.latitude}, '
      '${(_displayedRiderLatLng ?? riderLatLng)?.longitude})',
    );

    // Once delivered/completed/cancelled/disputed there's no rider left to
    // track — show the summary layout instead of a map with a stale pin.
    final showMap = riderLatLng != null && _orderStage < 3;

    return Scaffold(
      body: showMap
          ? _buildMapLayout(
              context,
              userLatLng,
              _displayedRiderLatLng ?? riderLatLng,
              displayAddress,
            )
          : _buildFallbackLayout(context),
    );
  }

  // ── Map layout (live telemetry available) ─────────────────────────────────

  Widget _buildMapLayout(
    BuildContext context,
    LatLng userLatLng,
    LatLng riderLatLng,
    String displayAddress,
  ) {
    return Stack(
      children: [
        // Full-screen map with route polyline
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: AppGoogleMap(
            initialTarget: riderLatLng,
            zoom: 16,
            onMapCreated: (c) {
              _mapController = c;
              // Trigger route draw now that the controller is ready
              _maybeRefreshRoute();
              _revealRiderLabel();
            },
            polylines: _polylines,
            markers: {
              Marker(
                markerId: const MarkerId('user_location'),
                position: userLatLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
                infoWindow: InfoWindow(
                  title: 'You',
                  snippet: displayAddress.isNotEmpty
                      ? displayAddress
                      : 'lat: ${userLatLng.latitude}, lng: ${userLatLng.longitude}',
                ),
              ),
              Marker(
                markerId: const MarkerId('rider'),
                position: riderLatLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange,
                ),
                infoWindow: InfoWindow(
                  title: 'Rider',
                  snippet: _liveData?.rider?.name ?? 'On the way',
                ),
              ),
            },
          ),
        ),

        // "Calculating route…" pill
        if (_routeLoading)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Calculating route…',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

        Positioned(
          top: 50,
          left: 16,
          child: _buildBackButton(context),
        ),
        Positioned(
          top: 50,
          right: 16,
          child: _buildRefreshButton(),
        ),

        // Persistent status card — ETA + live/stale badge, kept at the top
        // near the map so it's visible alongside the rider pin instead of
        // only in the bottom sheet.
        Positioned(
          top: 104,
          left: 16,
          right: 16,
          child: _buildTopStatusCard(),
        ),

        // Map FABs — re-center on rider + fit both points
        Positioned(
          right: 16,
          bottom: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMapFab(
                icon: Icons.my_location,
                tooltip: 'Centre on rider',
                onTap: () {
                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: riderLatLng, zoom: 16),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildMapFab(
                icon: Icons.fit_screen,
                tooltip: 'Fit route',
                onTap: () => _fitCamera([riderLatLng, userLatLng]),
              ),
            ],
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: _buildStatusSheet(context),
        ),
      ],
    );
  }

  Widget _buildMapFab({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
      ),
    );
  }

  // ── Fallback layout (no live telemetry) ───────────────────────────────────

  Widget _buildFallbackLayout(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(
              children: [
                _buildBackButton(context),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    'Order Tracking',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildRefreshButton(),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: _buildStatusSheet(context, scrollable: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.black,
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            AppNavigator.pushAndRemoveAll(
              context,
              AppRoute.dashboard,
              arguments: {'initialTab': 2},
            );
          }
        },
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh),
        color: Colors.black,
        onPressed: () {
          setState(() => _isLoading = true);
          _fetchLiveTracking();
        },
      ),
    );
  }

  Widget _buildTopStatusCard() {
    final eta = _liveData?.etaMinutes;
    final ageSeconds = _liveData?.ageSeconds;
    final isStale = _locationIsStale;
    final badgeColor = isStale ? Colors.red : Colors.green;
    final badgeLabel = isStale
        ? 'Stale${ageSeconds != null ? ' • ${_formatAge(ageSeconds)}' : ''}'
        : 'Live';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                _status,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _statusColor,
              ),
              const SizedBox(height: 2),
              AppText(
                eta != null ? 'ETA $eta mins' : 'Estimating…',
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                AppText(
                  badgeLabel,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAge(int seconds) {
    if (seconds < 60) return '${seconds}s ago';
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '${minutes}m ago';
    final hours = minutes ~/ 60;
    final remMinutes = minutes % 60;
    return remMinutes > 0 ? '${hours}h ${remMinutes}m ago' : '${hours}h ago';
  }

  Widget _buildStatusSheet(BuildContext context, {bool scrollable = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 16),
                    const Center(
                      child: SizedBox(
                        height: 2,
                        child: LinearProgressIndicator(
                          color: AppColors.primaryOrange,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                  if (_locationIsStale && !_isLoading) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.wifi_tethering_error_rounded,
                            size: 15,
                            color: Colors.amber.shade800,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText(
                              'Rider location may be slightly outdated. Refreshing…',
                              fontSize: 11,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Estimated Arrival',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            _liveData?.etaMinutes != null
                                ? '${_liveData!.etaMinutes} mins'
                                : '—',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          if (_prepTimeBreakdown != null) ...[
                            const SizedBox(height: 2),
                            AppText(
                              _prepTimeBreakdown!,
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppText(
                            'Status',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            _status,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _statusColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildProgressBar(context),
                  const SizedBox(height: 24),

                  // Hide rider info once delivered — show receipt/review instead.
                  if (_orderStage < 3) ...[
                    _buildRiderInfo(),
                    const SizedBox(height: 24),
                  ],

                  // Stage-based primary actions
                  if (_orderStage < 2) ...{
                    // Waiting — nothing actionable yet
                  } else if (_orderStage == 2) ...{
                    // IN_TRANSIT / PICKED_UP / ARRIVED_DROPOFF — show delivery OTP
                    if (_resolvedOtp != null) _buildDeliveryOtpCard(),
                  } else if (_orderStage >= 3) ...{
                    // Delivered / Completed — show review banner if already reviewed
                    if (_existingReview != null)
                      _buildReviewedBanner(_existingReview!),
                    if (_existingReview != null) const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () => AppNavigator.push(
                                context,
                                AppRoute.receipt,
                                arguments: {'orderId': widget.orderId},
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primaryOrange,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const AppText(
                                'View Receipt',
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _existingReview != null
                                  ? null
                                  : () => _showReviewSheet(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _existingReview != null
                                    ? Colors.grey.shade300
                                    : AppColors.primaryOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: AppText(
                                _existingReview != null
                                    ? 'Reviewed ✓'
                                    : 'Leave a Review',
                                color: _existingReview != null
                                    ? Colors.black54
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  },

                  // Share button — hidden for now.

                  // ── Cancel / Dispute quick actions ──────────────────────
                  if (_canCancel || _canDispute) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_canCancel)
                          TextButton.icon(
                            onPressed: () => _showCancelSheet(context),
                            icon: const Icon(
                              Icons.cancel_outlined,
                              size: 16,
                              color: Colors.red,
                            ),
                            label: const AppText(
                              'Cancel Order',
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (_canCancel && _canDispute)
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.grey.shade300,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        if (_canDispute)
                          TextButton.icon(
                            onPressed: () => _showDisputeSheet(context),
                            icon: const Icon(
                              Icons.report_problem_outlined,
                              size: 16,
                              color: Colors.red,
                            ),
                            label: AppText(
                              _currentState == 'DISPUTED'
                                  ? 'Add Evidence'
                                  : 'Dispute Order',
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],

                  // ── Locked actions affordance ─────────────────────────
                  if (_actionsLocked) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText(
                              'Cancel & dispute are unavailable while your order is in progress.',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
          );
  }

  // ─── Cancel bottom sheet ─────────────────────────────────────────────────

  Future<void> _showCancelSheet(BuildContext context) async {
    CancelReasonCode selectedReason = CancelReasonCode.customerChangedMind;
    final noteController = TextEditingController();

    // Wait for the sheet's own dismiss animation to finish (by awaiting the
    // showModalBottomSheet future itself) before acting on the result —
    // calling _submitCancel synchronously off the "Confirm Cancel" tap used
    // to show the success sheet while this one was still animating closed,
    // which looked like two modals stacked on top of each other.
    final result = await showModalBottomSheet<(CancelReasonCode, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const AppText(
                        'Cancel Order',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        'Please let us know why you\'re cancelling.',
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, size: 14, color: Colors.amber.shade800),
                                const SizedBox(width: 6),
                                AppText('Refund Policy', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                              ],
                            ),
                            const SizedBox(height: 6),
                            AppText(
                              '• You can cancel within 5 minutes of placing the order.\n'
                              '• Refunds are processed within 3 business days.\n'
                              '• Once your order is picked up, the service charge and rider fee are non-refundable.',
                              fontSize: 11,
                              color: Colors.amber.shade900,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reason picker
                      DropdownButtonFormField<CancelReasonCode>(
                        initialValue: selectedReason,
                        decoration: InputDecoration(
                          labelText: 'Reason',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        items: CancelReasonCode.values
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: AppText(r.displayLabel, fontSize: 14),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setSheetState(
                          () => selectedReason = v ?? selectedReason,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Optional note
                      TextField(
                        controller: noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Additional note (optional)',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => AppNavigator.pop(sheetCtx),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const AppText(
                                'Go Back',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(
                                sheetCtx,
                                (selectedReason, noteController.text.trim()),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const AppText(
                                'Confirm Cancel',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) return;
    await _submitCancel(result.$1, result.$2);
  }

  Future<void> _submitCancel(CancelReasonCode reason, String note) async {
    if (widget.orderId == null) return;

    try {
      final repo = ref.read(orderRepositoryProvider);
      final result = await repo.cancelOrder(
        widget.orderId!,
        CancelOrderRequest(
          reasonCode: reason.toApiString(),
          note: note.isNotEmpty ? note : reason.displayLabel,
        ),
      );
      if (mounted) {
        final walletRefunded = result.data.walletRefunded ?? false;
        await _showCancelSuccessSheet(walletRefunded: walletRefunded);
        if (mounted) {
          AppNavigator.pushAndRemoveAll(context, AppRoute.dashboard);
        }
      }
    } catch (e) {
      debugPrint('Cancel failed: $e');
      if (!mounted) return;

      String? errorCode;
      if (e is ApiException) {
        final body = e.data as Map<String, dynamic>?;
        final err = body?['error'] as Map<String, dynamic>?;
        errorCode = err?['code'] as String?;
      }

      if (errorCode == 'WINDOW_EXPIRED') {
        _showWindowExpiredSheet();
      } else {
        AppToast.showError(context, 'Failed to cancel order: $e');
      }
    }
  }

  Future<void> _showCancelSuccessSheet({required bool walletRefunded}) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.check_circle_outline,
                      color: Colors.green.shade600, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: AppText(
                    'Order Cancelled',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppText(
              walletRefunded
                  ? 'Your order has been cancelled. Your payment will be credited to your DropX wallet shortly.'
                  : 'Your order has been cancelled successfully.',
              fontSize: 14,
              color: AppColors.slate500,
              height: 1.55,
            ),
            if (walletRefunded) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        color: Colors.green.shade700, size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: AppText(
                        'Refund will appear in your wallet within a few minutes.',
                        fontSize: 13,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => AppNavigator.pop(sheetCtx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const AppText(
                  'Done',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWindowExpiredSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.timer_off_outlined,
                      color: Colors.orange.shade700, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: AppText(
                    'Cancellation Window Closed',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const AppText(
              'The cancellation window has closed because this order is already being processed. '
              'You can still track the order or contact support if you need help.',
              fontSize: 14,
              color: AppColors.slate500,
              height: 1.55,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => AppNavigator.pop(sheetCtx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const AppText(
                  'Track Order',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  AppNavigator.pop(sheetCtx);
                  AppNavigator.push(context, AppRoute.supportTickets);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const AppText(
                  'Contact Support',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dispute bottom sheet ────────────────────────────────────────────────

  void _showDisputeSheet(BuildContext context) {
    DisputeReasonCode selectedReason = DisputeReasonCode.itemMissing;
    final detailsController = TextEditingController();
    String? capturedEvidenceUrl;
    bool isUploading = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppText(
                        _currentState == 'DISPUTED'
                            ? 'Add More Evidence'
                            : 'Dispute Order',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        _currentState == 'DISPUTED'
                            ? 'Provide additional details or evidence for your dispute.'
                            : 'Our support team will review your dispute within 24 hours.',
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 20),

                      // Reason picker
                      DropdownButtonFormField<DisputeReasonCode>(
                        initialValue: selectedReason,
                        decoration: InputDecoration(
                          labelText: 'Issue',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        items: DisputeReasonCode.values
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: AppText(r.displayLabel, fontSize: 14),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setSheetState(
                          () => selectedReason = v ?? selectedReason,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Details
                      TextField(
                        controller: detailsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Details *',
                          hintText: 'Describe the issue in detail…',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Evidence upload area
                      GestureDetector(
                        onTap: isUploading
                            ? null
                            : () async {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(
                                  source: ImageSource.camera,
                                );
                                if (pickedFile != null) {
                                  setSheetState(() => isUploading = true);
                                  final file = File(pickedFile.path);
                                  final url =
                                      await CloudinaryUploadService.uploadImage(
                                        file,
                                      );
                                  setSheetState(() {
                                    isUploading = false;
                                    if (url != null) {
                                      capturedEvidenceUrl = url;
                                    }
                                  });
                                  if (context.mounted) {
                                    if (url != null) {
                                      AppToast.showSuccess(context, 'Evidence uploaded successfully.');
                                    } else {
                                      AppToast.showError(context, 'Failed to upload evidence.');
                                    }
                                  }
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: capturedEvidenceUrl != null
                                  ? AppColors.primaryOrange
                                  : Colors.grey.shade300,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              if (isUploading)
                                const CircularProgressIndicator(
                                  color: AppColors.primaryOrange,
                                )
                              else
                                Icon(
                                  capturedEvidenceUrl != null
                                      ? Icons.check_circle
                                      : Icons.camera_alt_outlined,
                                  color: capturedEvidenceUrl != null
                                      ? AppColors.primaryOrange
                                      : Colors.grey.shade400,
                                  size: 32,
                                ),
                              const SizedBox(height: 8),
                              AppText(
                                isUploading
                                    ? 'Uploading...'
                                    : capturedEvidenceUrl != null
                                    ? 'Evidence Attached'
                                    : 'Tap to capture evidence',
                                color: capturedEvidenceUrl != null
                                    ? AppColors.primaryOrange
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => AppNavigator.pop(sheetCtx),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const AppText(
                                'Go Back',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isUploading
                                  ? null
                                  : () async {
                                      AppNavigator.pop(sheetCtx);
                                      List<String>? urls;
                                      if (capturedEvidenceUrl != null) {
                                        urls = [capturedEvidenceUrl!];
                                      }
                                      await _submitDispute(
                                        selectedReason,
                                        detailsController.text.trim(),
                                        evidenceUrls: urls,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: AppText(
                                _currentState == 'DISPUTED'
                                    ? 'Submit Evidence'
                                    : 'Submit Dispute',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitDispute(
    DisputeReasonCode reason,
    String details, {
    List<String>? evidenceUrls,
  }) async {
    if (widget.orderId == null) {
      if (mounted) {
        AppToast.showSuccess(context, 'Dispute submitted (simulated).');
      }
      return;
    }

    try {
      final repo = ref.read(orderRepositoryProvider);
      await repo.disputeOrder(
        widget.orderId!,
        DisputeOrderRequest(
          reasonCode: reason.toApiString(),
          details: details.isNotEmpty ? details : reason.displayLabel,
          evidenceUrls: evidenceUrls,
        ),
      );
      if (mounted) {
        AppNavigator.pushAndRemoveAll(context, AppRoute.dashboard);
      }
    } catch (e) {
      debugPrint('Dispute failed: $e');
      if (mounted) {
        AppToast.showError(context, 'Failed to submit dispute: $e');
      }
    }
  }

  // ─── Review bottom sheet ──────────────────────────────────────────────────

  void _showReviewSheet(BuildContext context) {
    int rating = 5;
    final commentController = TextEditingController();
    final List<String> selectedTags = [];
    final availableTags = [
      'on_time',
      'friendly',
      'good_packaging',
      'super_fast',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const AppText(
                        'Rate your experience',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        'How was the delivery and the order?',
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 24),

                      // Star Rating
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                color: AppColors.primaryOrange,
                                size: 40,
                              ),
                              onPressed: () =>
                                  setSheetState(() => rating = index + 1),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableTags.map((tag) {
                          final isSelected = selectedTags.contains(tag);
                          return ChoiceChip(
                            label: AppText(
                              tag.replaceAll('_', ' '),
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: 12,
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primaryOrange,
                            backgroundColor: Colors.grey.shade100,
                            onSelected: (selected) {
                              setSheetState(() {
                                if (selected) {
                                  selectedTags.add(tag);
                                } else {
                                  selectedTags.remove(tag);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        'Select a tag, write a comment, or both',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(height: 16),

                      // Comment
                      TextField(
                        controller: commentController,
                        maxLines: 3,
                        onChanged: (_) => setSheetState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Comment',
                          hintText:
                              'Share more details about your experience...',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit — requires star + (tag or comment)
                      Builder(builder: (context) {
                        final hasContent =
                            selectedTags.isNotEmpty ||
                            commentController.text.trim().isNotEmpty;
                        final canSubmit = rating > 0 && hasContent;
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: canSubmit
                                ? () async {
                                    AppNavigator.pop(sheetCtx);
                                    await _submitReview(
                                      rating,
                                      commentController.text.trim(),
                                      selectedTags,
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: AppText(
                              'Submit Review',
                              color: canSubmit ? Colors.white : Colors.black38,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitReview(
    int rating,
    String comment,
    List<String> tags,
  ) async {
    if (widget.orderId == null) {
      if (mounted) {
        AppToast.showSuccess(context, 'Review submitted (simulated): $rating stars.');
      }
      return;
    }

    try {
      final repo = ref.read(orderRepositoryProvider);
      final response = await repo.submitReview(
        widget.orderId!,
        SubmitReviewRequest(
          ratingOverall: rating,
          ratingVendor: rating,
          comment: comment.isNotEmpty ? comment : null,
          tags: tags.isNotEmpty ? tags : null,
          reviewTarget: 'overall',
        ),
      );
      if (mounted) {
        setState(() {
          _existingReview = ReviewData(
            reviewId: response.data.reviewId,
            orderId: widget.orderId ?? '',
            ratingOverall: rating,
            comment: comment.isNotEmpty ? comment : null,
            tags: tags.isNotEmpty ? tags : null,
          );
        });
        AppToast.showSuccess(context, 'Thanks for your review!');
      }
    } catch (e) {
      debugPrint('Review submission failed: $e');
      if (mounted) {
        final errorMessage = (e.toString().contains('409') ||
                e.toString().contains('already exists'))
            ? 'Review already submitted for this order.'
            : 'Failed to submit review: $e';
        AppToast.showError(context, errorMessage);
      }
    }
  }

  // ─── Progress bar ─────────────────────────────────────────────────────────

  Widget _buildProgressBar(BuildContext context) {
    // Show a dedicated cancelled/disputed banner instead of the normal steps
    if (_currentState == 'CANCELLED' || _currentState == 'DISPUTED') {
      final isCancelled = _currentState == 'CANCELLED';
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(
              isCancelled ? Icons.cancel_outlined : Icons.report_problem_outlined,
              color: Colors.red,
              size: 20,
            ),
            const SizedBox(width: 10),
            AppText(
              isCancelled
                  ? 'This order has been cancelled.'
                  : 'A dispute has been raised for this order.',
              fontSize: 13,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      );
    }

    double progress = 0.0;
    if (_orderStage >= 1) progress = 0.33;
    if (_orderStage >= 2) progress = 0.66;
    if (_orderStage >= 3) progress = 1.0;

    final labels = ['Placed', 'Accepted', 'In Transit', 'Delivered'];

    return Column(
      children: [
        SizedBox(
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 4,
                width: double.infinity,
                color: Colors.grey.shade200,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 4,
                  width: (MediaQuery.of(context).size.width - 48) * progress,
                  color: AppColors.primaryOrange,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (i) {
                  final isActive = i <= _orderStage;
                  return Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryOrange
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 2),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels.map((l) {
            return AppText(l, fontSize: 9, color: Colors.grey.shade500);
          }).toList(),
        ),
      ],
    );
  }

  // ─── Reviewed banner ─────────────────────────────────────────────────────

  Widget _buildReviewedBanner(ReviewData review) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < review.ratingOverall ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber.shade600,
                  )),
                ),
                if (review.comment != null && review.comment!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AppText(
                    review.comment!,
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Rider info ───────────────────────────────────────────────────────────

  Widget _buildRiderInfo() {
    final rider = _liveData?.rider;
    final hasRider = rider != null;
    final riderName = rider?.name ?? 'Rider';

    // Build vehicle + plate subtitle from real API data.
    String? vehicleSubtitle;
    if (hasRider) {
      final parts = <String>[];
      if (rider.vehicle != null && rider.vehicle!.isNotEmpty) {
        parts.add(rider.vehicle!.toUpperCase());
      }
      if (rider.plateNumber != null && rider.plateNumber!.isNotEmpty) {
        parts.add(rider.plateNumber!.toUpperCase());
      }
      if (parts.isNotEmpty) vehicleSubtitle = parts.join(' • ');
    }

    // Avatar: photo URL if present, otherwise coloured circle with initials.
    Widget avatar;
    if (hasRider && rider.photoUrl != null && rider.photoUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(rider.photoUrl!),
      );
    } else {
      final initials = riderName.trim().isNotEmpty
          ? riderName.trim()[0].toUpperCase()
          : '?';
      avatar = CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primaryOrange,
        child: AppText(
          initials,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  hasRider ? riderName : 'Awaiting rider assignment',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                const SizedBox(height: 2),
                AppText(
                  hasRider
                      ? (vehicleSubtitle ?? 'On the way')
                      : 'Your order is being processed',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
          if (hasRider) ...[
            // CircleAvatar(
            //   backgroundColor: Colors.white,
            //   radius: 18,
            //   child: Icon(
            //     Icons.message_outlined,
            //     size: 18,
            //     color: Colors.black87,
            //   ),
            // ),
            // const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                final phone = rider.phoneE164;
                if (phone != null && phone.isNotEmpty) {
                  launchUrl(Uri(scheme: 'tel', path: phone));
                } else {
                  AppToast.showError(context, 'Rider phone number not available.');
                }
              },
              child: const CircleAvatar(
                backgroundColor: Colors.black,
                radius: 18,
                child: Icon(Icons.call, size: 18, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Payment UI methods removed since delivery OTP replaces manual "Confirm and Pay"
}
