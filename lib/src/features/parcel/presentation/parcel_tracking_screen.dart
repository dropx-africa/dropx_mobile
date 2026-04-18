import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropx_mobile/src/common_widgets/app_google_map.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
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

class _ParcelTrackingScreenState extends ConsumerState<ParcelTrackingScreen> {
  ParcelDetail? _parcel;
  ParcelTrackingLiveData? _liveData;
  bool _isLoading = true;
  bool _locationIsStale = false;
  GoogleMapController? _mapController;
  StreamSubscription<SseEvent>? _sseSub;

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
    super.dispose();
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
    if (!mounted || event.type != 'parcel.state') return;
    try {
      final json = jsonDecode(event.data) as Map<String, dynamic>;
      final updated = ParcelTrackingLiveData.fromJson(json);
      setState(() {
        _liveData = updated;
        _locationIsStale = updated.isStale;
      });
      if (updated.location != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(updated.location!.lat, updated.location!.lng),
          ),
        );
      }
    } catch (_) {}
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
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(live.location!.lat, live.location!.lng),
            ),
          );
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

    return Scaffold(
      body: _buildMapLayout(context, userLatLng, riderLatLng),
    );
  }

  // ── Map layout (always shown) ─────────────────────────────────────────────

  Widget _buildMapLayout(
    BuildContext context,
    LatLng userLatLng,
    LatLng? riderLatLng,
  ) {
    final mapCenter = riderLatLng ?? userLatLng;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('delivery_location'),
        position: userLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Delivery Location'),
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
            onMapCreated: (c) => _mapController = c,
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

                  // Fee breakdown
                  if (p.feeBreakdown != null) ...[
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
          const AppText(
            'Fee Summary',
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          const SizedBox(height: 10),
          _feeRow(
            'Delivery Fee',
            CurrencyUtils.koboToNaira(p.feeBreakdown!.deliveryFeeKobo),
          ),
          _feeRow(
            'Insurance Fee',
            CurrencyUtils.koboToNaira(p.feeBreakdown!.insuranceFeeKobo),
          ),
          Divider(height: 14, color: Colors.grey.shade300),
          _feeRow(
            'Total',
            CurrencyUtils.koboToNaira(p.feeBreakdown!.totalKobo),
            bold: true,
            valueColor: AppColors.primaryOrange,
          ),
          if (p.paymentMethod != null) ...[
            Divider(height: 12, color: Colors.grey.shade200),
            Row(
              children: [
                Icon(
                  Icons.wallet_outlined,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
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

  Widget _feeRow(
    String label,
    double value, {
    bool bold = false,
    Color? valueColor,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          fontSize: 13,
          color: Colors.grey.shade700,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
        AppText(
          Formatters.formatNaira(value),
          fontSize: 13,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          color: valueColor ?? Colors.black87,
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
