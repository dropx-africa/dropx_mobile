import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropx_mobile/src/common_widgets/app_google_map.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/common_widgets/cost_breakdown_widget.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/core/utils/formatters.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_detail_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_tracking_live_response.dart';
import 'package:dropx_mobile/src/features/parcel/providers/parcel_providers.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:dropx_mobile/src/core/services/app_notifications.dart';

const _stateOrder = [
  'PENDING_PAYMENT',
  'REQUESTED',
  'ASSIGNED',
  'PICKED_UP',
  'IN_TRANSIT',
  'DELIVERED',
];

const _stateLabels = {
  'PENDING_PAYMENT': 'Awaiting Payment',
  'REQUESTED': 'Pickup Requested',
  'ASSIGNED': 'Rider Assigned',
  'PICKED_UP': 'Parcel Picked Up',
  'IN_TRANSIT': 'In Transit',
  'DELIVERED': 'Delivered',
  'COMPLETED': 'Completed',
  'CANCELLED': 'Cancelled',
  'DRAFT': 'Draft',
  'PAYMENT_PENDING': 'Awaiting Payment',
};

class ParcelTrackingScreen extends ConsumerStatefulWidget {
  final String parcelId;

  const ParcelTrackingScreen({super.key, required this.parcelId});

  @override
  ConsumerState<ParcelTrackingScreen> createState() =>
      _ParcelTrackingScreenState();
}

class _ParcelTrackingScreenState extends ConsumerState<ParcelTrackingScreen>
    with TickerProviderStateMixin {
  ParcelDetail? _parcel;
  ParcelTrackingLiveData? _liveData;
  bool _isLoading = true;
  bool _locationIsStale = false;
  GoogleMapController? _mapController;
  StreamSubscription<SseEvent>? _sseSub;
  String? _notifiedState;

  final _recipientCodeController = TextEditingController();
  bool _isConfirmingRecipient = false;
  String? _recipientConfirmationStatus;

  // The rider position actually rendered on the map — animates smoothly
  // toward each new fix instead of snapping, so the pin visibly glides
  // rather than looking static while the camera pans around it.
  LatLng? _displayedRiderLatLng;
  AnimationController? _riderAnimController;
  LatLng? _riderAnimFrom;
  LatLng? _riderAnimTo;

  @override
  void initState() {
    super.initState();
    _fetchAll();
    _subscribeToSse();
  }

  @override
  void dispose() {
    _sseSub?.cancel();
    _mapController?.dispose();
    _recipientCodeController.dispose();
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

  Future<void> _confirmRecipient() async {
    final code = _recipientCodeController.text.trim();
    if (code.isEmpty || _isConfirmingRecipient) return;

    setState(() => _isConfirmingRecipient = true);
    try {
      final repo = ref.read(parcelRepositoryProvider);
      final result = await repo.verifyRecipientConfirmation(
        widget.parcelId,
        code,
      );
      if (!mounted) return;
      setState(
        () => _recipientConfirmationStatus = result.recipientConfirmationStatus,
      );
      if (result.recipientConfirmationStatus == 'VERIFIED') {
        AppToast.showSuccess(context, 'Recipient confirmed!');
      } else {
        AppToast.showError(context, 'Code did not match. Please try again.');
      }
    } on ApiException catch (e) {
      if (mounted) AppToast.showError(context, e.message);
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Could not confirm recipient. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isConfirmingRecipient = false);
    }
  }

  void _subscribeToSse() {
    if (!mounted) return;
    _sseSub?.cancel();
    final client = ref.read(apiClientProvider);
    _sseSub = client
        .sseStream(ApiEndpoints.sseParcel(widget.parcelId))
        .listen(
          _onSseEvent,
          onDone: () => Future.delayed(
            const Duration(seconds: 3),
            () {
              if (mounted) _subscribeToSse();
            },
          ),
          onError: (_) => Future.delayed(
            const Duration(seconds: 5),
            () {
              if (mounted) _subscribeToSse();
            },
          ),
        );
  }

  void _onSseEvent(SseEvent event) {
    if (!mounted) return;

    // Heartbeat — silently re-fetch to catch any missed state updates,
    // unless there's nothing left to track.
    if (event.type == 'heartbeat') {
      if (_sseSub != null) _fetchLive();
      return;
    }

    if (event.type != 'parcel.state') return;
    try {
      final json = jsonDecode(event.data) as Map<String, dynamic>;
      final updated = ParcelTrackingLiveData.fromJson(json);
      setState(() {
        _liveData = updated;
        _locationIsStale = updated.isStale;
      });
      if (updated.location != null && _mapController != null) {
        final newPos = LatLng(updated.location!.lat, updated.location!.lng);
        _mapController!.animateCamera(CameraUpdate.newLatLng(newPos));
        _moveRiderMarker(newPos);
      }
      _maybeNotify(updated.state);
    } catch (_) {}
  }

  void _maybeNotify(String state) {
    if (state == _notifiedState) return;
    _notifiedState = state;
    AppNotifications.parcelStateChanged(state, widget.parcelId);
    _checkTerminalState(state);
  }

  static const _terminalParcelStates = {'DELIVERED', 'COMPLETED', 'CANCELLED'};

  /// Stops resuming this screen on a cold restart, and stops polling for a
  /// rider position, once the parcel reaches a state with nothing left to
  /// track.
  void _checkTerminalState(String state) {
    if (_terminalParcelStates.contains(state)) {
      ref.read(sessionServiceProvider).clearLastRoute();
      _sseSub?.cancel();
      _sseSub = null;
      _riderAnimController?.stop();
    }
  }

  Future<void> _fetchAll() async {
    await Future.wait([_fetchDetail(), _fetchLive()]);
  }

  Future<void> _fetchDetail() async {
    try {
      final repo = ref.read(parcelRepositoryProvider);
      final detail = await repo.getParcel(widget.parcelId);
      if (mounted) {
        setState(() {
          _parcel = detail;
          _isLoading = false;
        });
        _checkTerminalState(detail.state);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Could not load parcel: $e');
      }
    }
  }

  Future<void> _fetchLive() async {
    try {
      final repo = ref.read(parcelRepositoryProvider);
      final live = await repo.getParcelTrackingLive(widget.parcelId);
      if (mounted) {
        setState(() {
          _liveData = live;
          _locationIsStale = live.isStale;
        });
        if (live.location != null && _mapController != null) {
          final newPos = LatLng(live.location!.lat, live.location!.lng);
          _mapController!.animateCamera(CameraUpdate.newLatLng(newPos));
          _moveRiderMarker(newPos);
        }
      }
    } on ApiException catch (e) {
      if (e.statusCode == 503 && mounted) {
        setState(() => _locationIsStale = true);
      }
    } catch (_) {}
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  int _stageIndex(String state) {
    final idx = _stateOrder.indexOf(state);
    return idx < 0 ? 0 : idx;
  }

  Color _stateColor(String state) {
    switch (state) {
      case 'DELIVERED':
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'IN_TRANSIT':
      case 'PICKED_UP':
        return AppColors.primaryOrange;
      default:
        return Colors.blueGrey;
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionServiceProvider);
    final userLatLng = LatLng(session.savedLat, session.savedLng);

    final riderLatLng = _liveData?.location != null
        ? LatLng(_liveData!.location!.lat, _liveData!.location!.lng)
        : null;

    if (_isLoading && _parcel == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
      );
    }

    if (_parcel == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: _buildError(),
      );
    }

    // Once delivered/completed/cancelled there's no rider left to track —
    // drop the pin instead of continuing to show a stale position.
    final isTracking = !_terminalParcelStates.contains(_liveData?.state ?? '');

    return Scaffold(
      body: _buildMapLayout(
        context,
        userLatLng,
        isTracking ? (_displayedRiderLatLng ?? riderLatLng) : null,
      ),
    );
  }

  // ── Map layout (always shown) ─────────────────────────────────────────────

  Widget _buildMapLayout(
    BuildContext context,
    LatLng userLatLng,
    LatLng? riderLatLng,
  ) {
    final mapCenter = riderLatLng ?? userLatLng;
    debugPrint(
      '🐎 [MARKER] build → rider marker position=(${riderLatLng?.latitude}, ${riderLatLng?.longitude})',
    );

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('delivery_location'),
        position: userLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'You'),
      ),
    };
    if (riderLatLng != null) {
      markers.add(
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
      );
    }

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: AppGoogleMap(
            initialTarget: mapCenter,
            zoom: 15,
            onMapCreated: (c) {
              _mapController = c;
              _revealRiderLabel();
            },
            markers: markers,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: _buildBackButton(context),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 16,
          child: _buildRefreshButton(),
        ),
        // Persistent status card — ETA + live/stale badge, kept at the top
        // near the map so it's visible alongside the rider pin instead of
        // only in the bottom sheet.
        Positioned(
          top: MediaQuery.of(context).padding.top + 62,
          left: 16,
          right: 16,
          child: _buildTopStatusCard(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildStatusSheet(context),
        ),
      ],
    );
  }

  // ── Status sheet (bottom overlay) ────────────────────────────────────────

  Widget _buildStatusSheet(BuildContext context) {
    final p = _parcel!;
    final state = p.state;
    final stateLabel = _stateLabels[state] ?? state;
    final stateColor = _stateColor(state);
    final isCancelled = state == 'CANCELLED';
    final isDelivered =
        state == 'DELIVERED' || state == 'COMPLETED';
    final stageIdx = _stageIndex(state);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
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
        children: [
          // Drag handle
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),

          // Loading indicator
          if (_isLoading)
            const LinearProgressIndicator(
              color: AppColors.primaryOrange,
              backgroundColor: Colors.transparent,
            ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ETA + Status row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'ETA',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            _liveData?.etaMinutes != null
                                ? '${_liveData!.etaMinutes} min'
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
                            stateLabel,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: stateColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stale location warning
                  if (_locationIsStale) ...[
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
                              'Rider location may be slightly outdated.',
                              fontSize: 11,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Progress stepper
                  if (!isCancelled && !isDelivered) ...[
                    _buildProgressBar(stageIdx),
                    const SizedBox(height: 16),
                  ],

                  // Delivered banner
                  if (isDelivered) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          AppText(
                            'Parcel delivered successfully!',
                            fontSize: 13,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Cancelled banner
                  if (isCancelled) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          AppText(
                            'This parcel has been cancelled.',
                            fontSize: 13,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Rider info
                  if (_liveData?.rider != null) ...[
                    _buildRiderCard(_liveData!.rider!),
                    const SizedBox(height: 16),
                  ],

                  // Recipient confirmation — customer enters the code the
                  // recipient shares during handoff.
                  if ((_liveData?.recipientConfirmationRequired ?? false) &&
                      (_recipientConfirmationStatus ??
                              _liveData?.recipientConfirmationStatus) !=
                          'VERIFIED') ...[
                    _buildRecipientConfirmationCard(),
                    const SizedBox(height: 16),
                  ],

                  // Fee breakdown
                  if (p.costBreakdown != null || p.feeBreakdown != null) ...[
                    _buildFeeSection(p),
                    const SizedBox(height: 16),
                  ],

                  // Parcel ID
                  AppText(
                    'Parcel ID: ${p.parcelId}',
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int stageIdx) {
    double progress = 0.0;
    if (stageIdx >= 1) progress = 0.2;
    if (stageIdx >= 2) progress = 0.4;
    if (stageIdx >= 3) progress = 0.6;
    if (stageIdx >= 4) progress = 0.8;
    if (stageIdx >= 5) progress = 1.0;

    final labels = ['Pending', 'Requested', 'Assigned', 'Picked Up', 'Transit', 'Delivered'];

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
                children: List.generate(_stateOrder.length, (i) {
                  final isActive = i <= stageIdx;
                  return Container(
                    width: 14,
                    height: 14,
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
          children: labels
              .map((l) => AppText(l, fontSize: 8, color: Colors.grey.shade500))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFeeSection(ParcelDetail p) {
    final fb = p.feeBreakdown;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('Fee Summary', fontWeight: FontWeight.bold, fontSize: 13),
          const SizedBox(height: 10),
          CostBreakdownWidget(
            costBreakdown: p.costBreakdown,
            fallbackRows: fb != null
                ? [
                    costRow('Delivery Fee', Formatters.formatNaira(CurrencyUtils.koboToNaira(fb.deliveryFeeKobo))),
                    costRow('Insurance Fee', Formatters.formatNaira(CurrencyUtils.koboToNaira(fb.insuranceFeeKobo))),
                    costRow('Total', Formatters.formatNaira(CurrencyUtils.koboToNaira(fb.totalKobo)), isTotal: true),
                  ]
                : [],
          ),
          if (p.paymentMethod != null) ...[
            Divider(height: 12, color: Colors.grey.shade200),
            Row(
              children: [
                Icon(Icons.wallet_outlined, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                AppText(
                  _formatPaymentMethod(p.paymentMethod!),
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRiderCard(ParcelTrackingRider rider) {
    final parts = <String>[];
    if (rider.vehicle != null && rider.vehicle!.isNotEmpty) {
      parts.add(rider.vehicle!.toUpperCase());
    }
    if (rider.plateNumber != null && rider.plateNumber!.isNotEmpty) {
      parts.add(rider.plateNumber!.toUpperCase());
    }
    final subtitle = parts.isNotEmpty ? parts.join(' • ') : 'On the way';

    Widget avatar;
    if (rider.photoUrl != null && rider.photoUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(rider.photoUrl!),
      );
    } else {
      final initials =
          rider.name.trim().isNotEmpty
              ? rider.name.trim()[0].toUpperCase()
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
                AppText(rider.name, fontWeight: FontWeight.bold, fontSize: 14),
                const SizedBox(height: 2),
                AppText(subtitle, fontSize: 12, color: Colors.grey.shade600),
              ],
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.black,
            radius: 18,
            child: const Icon(Icons.call, size: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientConfirmationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primaryOrange.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Confirm Recipient',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryOrange,
          ),
          const SizedBox(height: 4),
          AppText(
            'Ask the recipient for the code they received and enter it here.',
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _recipientCodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: 'Enter code',
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isConfirmingRecipient ? null : _confirmRecipient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isConfirmingRecipient
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const AppText(
                        'Confirm',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatusCard() {
    final state = _liveData?.state ?? _parcel?.state ?? '';
    final stateLabel = _stateLabels[state] ?? state;
    final stateColor = _stateColor(state);
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
                stateLabel,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: stateColor,
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
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoute.dashboard,
          (route) => false,
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
          _fetchAll();
        },
      ),
    );
  }

  Widget _buildError() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 56, color: Colors.grey),
        const SizedBox(height: 12),
        const AppText('Could not load parcel details'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() => _isLoading = true);
            _fetchAll();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
          ),
          child: const AppText('Retry', color: Colors.white),
        ),
      ],
    ),
  );

  String _formatPaymentMethod(String method) => switch (method) {
    'PAYSTACK' => 'Card / Transfer',
    'WALLET' => 'DropX Wallet',
    'GENERATE_LINK' => 'Payment Link',
    _ => method.replaceAll('_', ' '),
  };
}
