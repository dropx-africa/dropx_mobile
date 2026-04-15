import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/core/utils/formatters.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_detail_response.dart';
import 'package:dropx_mobile/src/features/parcel/providers/parcel_providers.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';

// ─── State ordering ────────────────────────────────────────────────────────

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
  bool _isLoading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetch();
    // Poll every 15 s while screen is open and parcel is not terminal.
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _fetch());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final repo = ref.read(parcelRepositoryProvider);
      final detail = await repo.getParcel(widget.parcelId);
      if (mounted) {
        setState(() {
          _parcel = detail;
          _isLoading = false;
        });
        // Stop polling once terminal.
        final s = detail.state;
        if (s == 'DELIVERED' || s == 'COMPLETED' || s == 'CANCELLED') {
          _pollTimer?.cancel();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Could not load parcel: $e');
      }
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

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

  IconData _stateIcon(String state) {
    switch (state) {
      case 'PENDING_PAYMENT':
      case 'PAYMENT_PENDING':
        return Icons.payment_outlined;
      case 'REQUESTED':
        return Icons.access_time_outlined;
      case 'ASSIGNED':
        return Icons.delivery_dining_outlined;
      case 'PICKED_UP':
        return Icons.inventory_2_outlined;
      case 'IN_TRANSIT':
        return Icons.local_shipping_outlined;
      case 'DELIVERED':
      case 'COMPLETED':
        return Icons.check_circle_outline;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const AppText(
          'Track Parcel',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoute.dashboard,
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetch();
            },
          ),
        ],
      ),
      body: _isLoading && _parcel == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            )
          : _parcel == null
          ? _buildError()
          : _buildContent(_parcel!),
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
            _fetch();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
          ),
          child: const AppText('Retry', color: Colors.white),
        ),
      ],
    ),
  );

  Widget _buildContent(ParcelDetail p) {
    final state = p.state;
    final stateLabel = _stateLabels[state] ?? state;
    final stateColor = _stateColor(state);
    final isCancelled = state == 'CANCELLED';
    final stageIdx = _stageIndex(state);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status hero card ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: stateColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_stateIcon(state), color: stateColor, size: 32),
                ),
                const SizedBox(height: 12),
                AppText(
                  stateLabel,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: stateColor,
                ),
                const SizedBox(height: 4),
                AppSubText(
                  'Parcel ID: ${p.parcelId}',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Progress stepper (skipped for cancelled) ──────────────────────
          if (!isCancelled) ...[
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'Delivery Progress',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_stateOrder.length, (i) {
                    final stepState = _stateOrder[i];
                    final label = _stateLabels[stepState] ?? stepState;
                    final isDone = i < stageIdx;
                    final isCurrent = i == stageIdx;
                    final isLast = i == _stateOrder.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Line + dot
                        SizedBox(
                          width: 24,
                          child: Column(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDone || isCurrent
                                      ? AppColors.primaryOrange
                                      : Colors.grey.shade300,
                                  border: isCurrent
                                      ? Border.all(
                                          color: AppColors.primaryOrange,
                                          width: 3,
                                        )
                                      : null,
                                ),
                                child: isDone
                                    ? const Icon(
                                        Icons.check,
                                        size: 10,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 32,
                                  color: isDone
                                      ? AppColors.primaryOrange
                                      : Colors.grey.shade200,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(top: 1, bottom: 8),
                          child: AppText(
                            label,
                            fontSize: 13,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isCurrent
                                ? Colors.black
                                : isDone
                                ? Colors.grey
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Fee breakdown ─────────────────────────────────────────────────
          if (p.feeBreakdown != null) ...[
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'Fee Breakdown',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 12),
                  _feeRow(
                    'Delivery Fee',
                    CurrencyUtils.koboToNaira(
                      p.feeBreakdown!.deliveryFeeKobo,
                    ),
                  ),
                  _feeRow(
                    'Insurance Fee',
                    CurrencyUtils.koboToNaira(
                      p.feeBreakdown!.insuranceFeeKobo,
                    ),
                  ),
                  const Divider(height: 16),
                  _feeRow(
                    'Total',
                    CurrencyUtils.koboToNaira(p.feeBreakdown!.totalKobo),
                    bold: true,
                    valueColor: AppColors.primaryOrange,
                  ),
                  if (p.paymentMethod != null) ...[
                    const Divider(height: 12),
                    _infoRow(
                      Icons.wallet_outlined,
                      'Payment',
                      _formatPaymentMethod(p.paymentMethod!),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Parcel info ───────────────────────────────────────────────────
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Parcel Info',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                const SizedBox(height: 12),
                _infoRow(Icons.info_outline, 'Status', stateLabel, valueColor: stateColor),
                if (p.assignmentStatus != null)
                  _infoRow(
                    Icons.assignment_ind_outlined,
                    'Assignment',
                    p.assignmentStatus!.replaceAll('_', ' '),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Home button ───────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoute.dashboard,
                (route) => false,
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(Icons.home_outlined, color: Colors.grey.shade700),
              label: AppText(
                'Back to Home',
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helper widgets ────────────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );

  Widget _feeRow(
    String label,
    double value, {
    bool bold = false,
    Color? valueColor,
  }) =>
      Padding(
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

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade500),
            const SizedBox(width: 10),
            AppText(label, fontSize: 13, color: Colors.grey.shade600),
            const Spacer(),
            AppText(
              value,
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
