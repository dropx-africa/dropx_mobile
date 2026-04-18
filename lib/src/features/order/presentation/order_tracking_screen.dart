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
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
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

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  // UI stage index: 0=Placed, 1=Accepted/Picked up, 2=In Transit, 3=Delivered, 4=Completed
  int _orderStage = 0;
  String _status = 'Order Placed';
  Color _statusColor = Colors.grey;

  // Whether we are still waiting for the very first data fetch
  bool _isLoading = false;

  // True when the last tracking call returned TRACKING_STALE (503)
  bool _locationIsStale = false;

  // Live data
  OrderTrackingLiveData? _liveData;

  // Delivery OTP (fetched from dedicated endpoint when rider is in transit)
  DeliveryOtpData? _deliveryOtpData;

  GoogleMapController? _mapController;
  StreamSubscription<SseEvent>? _sseSub;

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
    if (!mounted || event.type != 'order.state') return;
    try {
      final json = jsonDecode(event.data) as Map<String, dynamic>;
      final updated = OrderTrackingLiveData.fromJson(json);
      setState(() {
        _liveData = updated;
        _locationIsStale = updated.isStale ?? false;
        _applyState(updated.state);
      });
      if (updated.location != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(updated.location!.lat, updated.location!.lng),
          ),
        );
      }
      final state = updated.state;
      if (state == 'IN_TRANSIT' ||
          state == 'PICKED_UP' ||
          state == 'ARRIVED_DROPOFF') {
        _fetchDeliveryOtp();
      }
    } catch (_) {}
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
          _locationIsStale = false;
          _applyState(_liveData?.state ?? 'PLACED');
          if (_liveData?.location != null && _mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(_liveData!.location!.lat, _liveData!.location!.lng),
              ),
            );
          }
        });
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

  /// The best available OTP string — from the dedicated endpoint, or from
  /// live tracking data. Returns null when no OTP is available yet.
  String? get _resolvedOtp =>
      _deliveryOtpData?.deliveryOtp ?? _liveData?.deliveryOtp;

  /// Map API state string → local stage + labels.
  void _applyState(String state) {
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
      case 'COMPLETED':
        _orderStage = 4;
        _status = 'Completed';
        _statusColor = Colors.green;
      case 'CANCELLED':
        _orderStage = 0;
        _status = 'Cancelled';
        _statusColor = Colors.red;
      case 'DISPUTED':
        _orderStage = 0;
        _status = 'Disputed';
        _statusColor = Colors.red;
      default:
        _orderStage = 1;
        _status = 'On the Way';
        _statusColor = AppColors.primaryOrange;
    }
  }

  @override
  void dispose() {
    _sseSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ─── Delivery OTP card ───────────────────────────────────────────────────

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
        ],
      ),
    );
  }

  // ─── Cancel / Dispute state helpers ─────────────────────────────────────

  /// The current authoritative state string.
  String get _currentState => _liveData?.state ?? 'PLACED';

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

    return Scaffold(
      body: riderLatLng != null
          ? _buildMapLayout(context, userLatLng, riderLatLng, displayAddress)
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
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: AppGoogleMap(
            initialTarget: riderLatLng,
            zoom: 16,
            onMapCreated: (c) => _mapController = c,
            markers: {
              Marker(
                markerId: const MarkerId('user_location'),
                position: userLatLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
                infoWindow: InfoWindow(
                  title: 'Delivery Location',
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
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildStatusSheet(context),
        ),
      ],
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
        onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoute.dashboard,
          (route) => false,
          arguments: {'initialTab': 2},
        ),
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

                  _buildRiderInfo(),
                  const SizedBox(height: 24),

                  // Stage-based primary actions
                  if (_orderStage < 2) ...{
                    // Waiting — nothing actionable yet
                  } else if (_orderStage == 2) ...{
                    // IN_TRANSIT / PICKED_UP / ARRIVED_DROPOFF — show delivery OTP
                    if (_resolvedOtp != null) _buildDeliveryOtpCard(),
                  } else if (_orderStage >= 3) ...{
                    // Completed / Delivered actions
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoute.receipt,
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
                              onPressed: () => _showReviewSheet(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const AppText(
                                'Leave a Review',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  },

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

  void _showCancelSheet(BuildContext context) {
    CancelReasonCode selectedReason = CancelReasonCode.customerChangedMind;
    final noteController = TextEditingController();

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
                              onPressed: () => Navigator.pop(sheetCtx),
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
                              onPressed: () async {
                                Navigator.pop(sheetCtx);
                                await _submitCancel(
                                  selectedReason,
                                  noteController.text.trim(),
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
  }

  Future<void> _submitCancel(CancelReasonCode reason, String note) async {
    if (widget.orderId == null) return;

    try {
      final repo = ref.read(orderRepositoryProvider);
      await repo.cancelOrder(
        widget.orderId!,
        CancelOrderRequest(
          reasonCode: reason.toApiString(),
          note: note.isNotEmpty ? note : reason.displayLabel,
        ),
      );
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoute.dashboard,
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Cancel failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to cancel order: $e')));
      }
    }
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
                                final messenger = ScaffoldMessenger.of(context);
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
                                  if (url != null) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Evidence uploaded successfully.',
                                        ),
                                      ),
                                    );
                                  } else {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Failed to upload evidence.',
                                        ),
                                      ),
                                    );
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
                              onPressed: () => Navigator.pop(sheetCtx),
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
                                      Navigator.pop(sheetCtx);
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispute submitted (simulated).')),
        );
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
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoute.dashboard,
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Dispute failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit dispute: $e')));
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
                      const SizedBox(height: 24),

                      // Comment
                      TextField(
                        controller: commentController,
                        maxLines: 3,
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

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(sheetCtx);
                            await _submitReview(
                              rating,
                              commentController.text.trim(),
                              selectedTags,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const AppText(
                            'Submit Review',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
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

  Future<void> _submitReview(
    int rating,
    String comment,
    List<String> tags,
  ) async {
    if (widget.orderId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review submitted (simulated): $rating stars.'),
          ),
        );
      }
      return;
    }

    try {
      final repo = ref.read(orderRepositoryProvider);
      await repo.submitReview(
        widget.orderId!,
        SubmitReviewRequest(
          ratingOverall: rating,
          comment: comment.isNotEmpty ? comment : null,
          tags: tags.isNotEmpty ? tags : null,
          reviewTarget: 'overall',
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks for your review!')),
        );
      }
    } catch (e) {
      debugPrint('Review submission failed: $e');
      if (mounted) {
        String errorMessage = 'Failed to submit review: $e';
        if (e.toString().contains('409') ||
            e.toString().contains('already exists')) {
          errorMessage = 'Review already submitted for this order.';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
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
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Icon(
                Icons.message_outlined,
                size: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.black,
              radius: 18,
              child: Icon(Icons.call, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  // Payment UI methods removed since delivery OTP replaces manual "Confirm and Pay"
}
