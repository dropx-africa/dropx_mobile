import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/cost_breakdown_widget.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/core/utils/formatters.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';
import 'package:dropx_mobile/src/features/order/providers/order_providers.dart';
import 'package:dropx_mobile/src/models/order.dart';
import 'package:dropx_mobile/src/models/order_item.dart';
import 'package:dropx_mobile/src/route/page.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> orderDetails;

  const ReceiptScreen({super.key, required this.orderDetails});

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  final _receiptKey = GlobalKey();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderDetails['orderId'] as String?;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const AppText('Receipt', fontWeight: FontWeight.bold),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: orderId == null
          ? _buildError(context, 'No order ID provided')
          : ref.watch(orderByIdProvider(orderId)).when(
              loading: () => const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryOrange),
              ),
              error: (_, __) =>
                  _buildError(context, 'Could not load receipt'),
              data: (order) => _buildReceipt(context, order),
            ),
    );
  }

  Widget _buildReceipt(BuildContext context, Order order) {
    final items = order.items ?? [];

    final subtotalKobo = items.fold<int>(
      0,
      (sum, item) => sum + item.qty * item.unitPriceKobo,
    );
    final totalKobo = int.tryParse(order.totalAmountKobo) ?? subtotalKobo;
    final feesKobo = (totalKobo - subtotalKobo).clamp(0, totalKobo);

    final subtotal = CurrencyUtils.koboToNaira(subtotalKobo);
    final fees = CurrencyUtils.koboToNaira(feesKobo);
    final total = CurrencyUtils.koboToNaira(totalKobo);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Shareable receipt card ────────────────────────────────────────
          RepaintBoundary(
            key: _receiptKey,
            child: Container(
              color: Colors.white, // solid bg so screenshot has no transparency
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: logo + success indicator
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/dropx_logo.png',
                            height: 48,
                          ),
                          AppSpaces.v16,
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 32,
                            ),
                          ),
                          AppSpaces.v16,
                          const AppText(
                            'Payment Successful',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          AppSpaces.v4,
                          AppText(
                            'Order #${order.orderId}',
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ],
                      ),
                    ),

                    AppSpaces.v24,
                    const Divider(),
                    AppSpaces.v16,

                    // Items
                    if (items.isNotEmpty) ...[
                      const AppText(
                        'Items Ordered',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      AppSpaces.v12,
                      ...items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildItemRow(item),
                          )),
                      AppSpaces.v16,
                      const Divider(),
                      AppSpaces.v16,
                    ],

                    // Bill breakdown
                    CostBreakdownWidget(
                      costBreakdown: order.costBreakdown,
                      fallbackRows: [
                        costRow(
                            'Subtotal', Formatters.formatNaira(subtotal)),
                        costRow('Delivery & Service Fees',
                            Formatters.formatNaira(fees)),
                        costRow('Total Paid', Formatters.formatNaira(total),
                            isTotal: true),
                      ],
                    ),

                    // Footer watermark inside the card
                    AppSpaces.v20,
                    const Divider(),
                    AppSpaces.v12,
                    Center(
                      child: AppText(
                        'Powered by DropX',
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          AppSpaces.v32,

          // ── Share as image ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSharing ? null : () => _shareReceiptImage(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                disabledBackgroundColor:
                    AppColors.primaryOrange.withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isSharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.share_outlined,
                      color: Colors.white, size: 18),
              label: AppText(
                _isSharing ? 'Preparing…' : 'Share Receipt',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          AppSpaces.v12,

          CustomButton(
            text: 'Back to Home',
            backgroundColor: AppColors.darkBackground,
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoute.dashboard,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _shareReceiptImage(Order order) async {
    if (!mounted) return;
    setState(() => _isSharing = true);

    try {
      // Give Flutter one frame to settle before capturing.
      await Future.delayed(const Duration(milliseconds: 80));

      final boundary = _receiptKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/dropx_receipt_${order.orderId}.png');
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'My DropX receipt 🧾',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share receipt: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Widget _buildItemRow(OrderItem item) {
    final lineTotal =
        CurrencyUtils.koboToNaira(item.qty * item.unitPriceKobo);
    return Row(
      children: [
        Expanded(
          child: AppText(
            '${item.name ?? ''} × ${item.qty}',
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        AppText(
          Formatters.formatNaira(lineTotal),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(message, color: Colors.grey.shade600),
            AppSpaces.v24,
            CustomButton(
              text: 'Back to Home',
              backgroundColor: AppColors.darkBackground,
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoute.dashboard,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
