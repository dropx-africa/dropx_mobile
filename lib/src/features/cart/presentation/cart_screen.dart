import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/cart/providers/cart_provider.dart';
import 'package:dropx_mobile/src/features/wallet/providers/wallet_providers.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_topup_initialize_request.dart';
import 'package:dropx_mobile/src/core/utils/formatters.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/features/order/data/dto/create_order_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/create_order_item_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/initialize_payment_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/place_order_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/generate_payment_link_dto.dart';
import 'package:dropx_mobile/src/features/order/data/dto/estimate_order_request.dart';
import 'package:dropx_mobile/src/features/order/providers/order_providers.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';
import 'package:dropx_mobile/src/features/vendor/providers/vendor_providers.dart';
import 'package:dropx_mobile/src/models/vendor.dart';
import 'package:dropx_mobile/src/features/location/data/address_models.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/common_widgets/app_empty_state.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isLoadingEstimate = false;
  String _selectedPaymentMethod = 'PAYSTACK';
  double _deliveryFee = 0.0;
  double _serviceFee = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEstimate();
    });
  }

  Future<void> _loadEstimate() async {
    final cartState = ref.read(cartProvider);

    if (cartState.vendorId == null ||
        cartState.zoneId == null ||
        cartState.items.isEmpty) {
      setState(() {
        _deliveryFee = 0.0;
        _serviceFee = 0.0;
      });
      return;
    }

    setState(() => _isLoadingEstimate = true);

    try {
      final session = ref.read(sessionServiceProvider);
      final orderRepo = ref.read(orderRepositoryProvider);
      final addressRepo = ref.read(addressRepositoryProvider);

      final deliveryLat = session.savedLat;
      final deliveryLng = session.savedLng;
      final savedAddress = session.savedAddress;

      String? deliveryAddressId;
      try {
        final createdAddress = await addressRepo.createAddress(
          CreateAddressRequest(
            label: 'Delivery',
            line1: savedAddress.isNotEmpty ? savedAddress : 'My Location',
            city: session.savedCity.isNotEmpty ? session.savedCity : 'Lagos',
            state: session.savedState.isNotEmpty ? session.savedState : 'Lagos',
            lat: deliveryLat,
            lng: deliveryLng,
          ),
        );
        deliveryAddressId = createdAddress.addressId;
      } catch (e) {
        debugPrint('❌ [CART] Address save FAILED (using fallback): $e');
      }

      final orderItems = cartState.items.values.map((cartItem) {
        return EstimateOrderItem(
          itemId: cartItem.menuItem.id,
          name: cartItem.menuItem.name,
          qty: cartItem.quantity,
          unitPriceKobo: CurrencyUtils.nairaToKobo(cartItem.menuItem.price),
        );
      }).toList();

      final dto = EstimateOrderRequest(
        zoneId: cartState.zoneId!,
        vendorId: cartState.vendorId!,
        items: orderItems,
        deliveryAddressId: deliveryAddressId ?? 'address-1',
        deliveryLat: deliveryLat,
        deliveryLng: deliveryLng,
        serviceTier: 'STANDARD',
      );

      final response = await orderRepo.estimateOrder(dto);

      if (mounted) {
        setState(() {
          _deliveryFee = CurrencyUtils.koboToNaira(
            int.parse(response.data.deliveryFeeKobo),
          );
          _serviceFee = CurrencyUtils.koboToNaira(
            int.parse(response.data.serviceFeeKobo),
          );
        });
      }
    } catch (e) {
      if (mounted) debugPrint('❌ [CART] _loadEstimate FAILED: $e');
    } finally {
      if (mounted) setState(() => _isLoadingEstimate = false);
    }
  }

  Future<void> _placeOrder() async {
    final cartState = ref.read(cartProvider);
    final session = ref.read(sessionServiceProvider);
    final orderRepo = ref.read(orderRepositoryProvider);

    final vendorId = cartState.vendorId;
    final zoneId = cartState.zoneId;
    final deliveryAddress = session.savedAddress;

    if (vendorId == null || zoneId == null) {
      AppToast.showError(
        context,
        'Unable to place order. Please add items from a vendor.',
      );
      return;
    }

    try {
      final orderItems = cartState.items.values.map((cartItem) {
        return CreateOrderItemDto(
          name: cartItem.menuItem.name,
          qty: cartItem.quantity,
          unitPriceKobo: CurrencyUtils.nairaToKobo(cartItem.menuItem.price),
        );
      }).toList();

      final createDto = CreateOrderDto(
        vendorId: vendorId,
        zoneId: zoneId,
        deliveryAddress: deliveryAddress,
        items: orderItems,
      );

      final orderResponse = await orderRepo.createOrder(createDto);
      final orderId = orderResponse.order.orderId;

      if (_selectedPaymentMethod == 'WALLET') {
        await orderRepo.placeOrder(
          orderId,
          PlaceOrderDto(paymentMethod: 'WALLET'),
        );
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoute.orderSuccess,
          (route) => false,
        );
      } else if (_selectedPaymentMethod == 'GENERATE_LINK') {
        final linkResponse = await orderRepo.generatePaymentLink(
          orderId,
          GeneratePaymentLinkDto(ttlMinutes: 30),
        );
        if (!mounted) return;

        final shareableLink =
            'https://dropxwebapp.vercel.app/pay-link/${linkResponse.token}';

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const AppText(
              'Payment Link Generated',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Share this link with your friend to complete the payment:',
                  fontSize: 14,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          shareableLink,
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: shareableLink));
                          AppToast.showSuccess(
                            context,
                            'Link copied to clipboard!',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => AppNavigator.pop(context),
                child: const AppText(
                  'View Order',
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
        if (!mounted) return;
        ref.read(cartProvider.notifier).clearCart();
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoute.dashboard,
          (route) => false,
          arguments: {'initialTab': 2},
        );
      } else {
        // PAYSTACK: place the order first (DRAFT → PAYMENT_PENDING),
        // then initialize Paystack to get the checkout URL.
        await orderRepo.placeOrder(
          orderId,
          PlaceOrderDto(paymentMethod: 'PAYSTACK'),
        );
        final paymentResponse = await orderRepo.initializePayment(
          InitializePaymentDto(orderId: orderId),
        );
        if (!mounted) return;
        AppNavigator.push(
          context,
          AppRoute.paystackCheckout,
          arguments: {
            'authorizationUrl': paymentResponse.authorizationUrl,
            'reference': paymentResponse.reference,
            'orderId': orderId,
          },
        );
      }
    } catch (e) {
      if (mounted)
        AppToast.showError(context, 'Failed to place order: ${e.toString()}');
    }
  }

  void _showPaymentSheet(double totalAmount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentBottomSheet(
        selectedPaymentMethod: _selectedPaymentMethod,
        totalAmount: totalAmount,
        onMethodChanged: (method) =>
            setState(() => _selectedPaymentMethod = method),
        onConfirm: () async {
          if (_selectedPaymentMethod == 'WALLET') {
            await _checkWalletBalanceAndProceed(totalAmount);
          } else {
            await _placeOrder();
          }
        },
      ),
    );
  }

  Future<void> _checkWalletBalanceAndProceed(double totalAmount) async {
    ref.invalidate(walletBalanceProvider);
    final walletBalance = await ref.read(walletBalanceProvider.future);
    final balanceKobo = int.tryParse(walletBalance.availableBalanceKobo) ?? 0;
    final balanceNaira = CurrencyUtils.koboToNaira(balanceKobo);
    ref.read(walletBalanceKoboProvider.notifier).state = balanceKobo;

    if (!mounted) return;

    if (balanceNaira < totalAmount) {
      Navigator.of(context).pop();
      _showTopupBottomSheet(totalAmount, balanceNaira);
    } else {
      Navigator.of(context).pop();
      await _placeOrder();
    }
  }

  Future<void> _showTopupBottomSheet(double totalAmount, double currentBalance) async {
    final topupData = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TopupBottomSheet(
        totalAmount: totalAmount,
        currentBalance: currentBalance,
      ),
    );

    if (topupData == null || !mounted) return;

    final success = await AppNavigator.push<bool>(
      context,
      AppRoute.walletTopupCheckout,
      arguments: topupData,
    );

    if (!mounted) return;

    if (success == true) {
      final balanceKobo = ref.read(walletBalanceKoboProvider);
      final balanceNaira = CurrencyUtils.koboToNaira(balanceKobo);
      AppToast.showSuccess(
        context,
        'Wallet topped up! New balance: ₦${balanceNaira.toStringAsFixed(0)}',
      );
      _showPaymentSheet(totalAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CartState>(cartProvider, (previous, next) {
      if (previous?.totalItemCount != next.totalItemCount) {
        _loadEstimate();
      }
    });

    final session = ref.read(sessionServiceProvider);
    final String displayAddress = session.savedAddress;
    final cartState = ref.watch(cartProvider);
    final cartItemsList = cartState.items.values.toList();
    final totalPrice = cartState.totalPrice;

    // Delivery fee fallback: use vendor's deliveryFeeNaira if estimate not yet loaded
    // final double vendorDeliveryFee = cartState.zoneId != null
    //     ? ref
    //           .watch(vendorsByZoneProvider(cartState.zoneId!))
    //           .maybeWhen(
    //             data: (vendors) {
    //               final v = vendors.cast<Vendor?>().firstWhere(
    //                 (v) => v?.id == cartState.vendorId,
    //                 orElse: () => vendors.isNotEmpty ? vendors.first : null,
    //               );
    //               return v?.deliveryFeeNaira ?? 0.0;
    //             },
    //             orElse: () => 0.0,
    //           )
    //     : 0.0;

    // final double displayDeliveryFee =
    //     _deliveryFee > 0 ? _deliveryFee : vendorDeliveryFee;
    final totalAmount = totalPrice + _deliveryFee + _serviceFee;

    return AppScaffold(
      appBar: SliverAppBar(
        title: const AppText(
          "My Cart",
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => AppNavigator.pop(context),
        ),
        floating: true,
        snap: true,
      ),
      slivers: [
        if (cartItemsList.isEmpty)
          SliverFillRemaining(
            child: AppEmptyState(
              icon: Icons.shopping_cart_outlined,
              title: "Your cart is empty",
              message: "Add items from a vendor to get started",
            ),
          )
        else ...[
          // Vendor Info
          if (cartState.zoneId != null)
            SliverToBoxAdapter(child: _buildVendorSection(cartState)),

          // Delivery Address
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        "DELIVER TO",
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                      GestureDetector(
                        onTap: () =>
                            AppNavigator.push(context, AppRoute.manualLocation),
                        child: const AppText(
                          "Change",
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: AppText(
                          displayAddress,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Cart Items
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: cartItemsList
                    .map((item) => _buildCartItem(ref, item))
                    .toList(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Bill Summary + Place Order button
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  _buildBillRow("Subtotal", Formatters.formatNaira(totalPrice)),
                  const SizedBox(height: 12),
                  _buildBillRow(
                    "Delivery Fee",
                    _isLoadingEstimate
                        ? '...'
                        : Formatters.formatNaira(_deliveryFee),
                  ),
                  const SizedBox(height: 12),
                  _buildBillRow(
                    "Service Fee",
                    _isLoadingEstimate
                        ? '...'
                        : Formatters.formatNaira(_serviceFee),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.grey, thickness: 0.5),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        "Total",
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      AppText(
                        _isLoadingEstimate
                            ? '...'
                            : Formatters.formatNaira(totalAmount),
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoadingEstimate
                          ? null
                          : () => _showPaymentSheet(totalAmount),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        disabledBackgroundColor: AppColors.primaryOrange
                            .withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoadingEstimate
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon(
                                //   Icons.lock_outline,
                                //   color: Colors.white,
                                //   size: 18,
                                // ),
                                // SizedBox(width: 8),
                                AppText(
                                  "Place Order",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCartItem(WidgetRef ref, CartItem cartItem) {
    final item = cartItem.menuItem;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: item.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(item.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: item.imageUrl == null ? Colors.grey.shade200 : null,
                ),
                child: item.imageUrl == null
                    ? const Icon(Icons.fastfood, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      item.name,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      item.description ?? '',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      Formatters.formatNaira(item.price),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () =>
                          ref.read(cartProvider.notifier).decrement(item.id),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Icon(Icons.remove, size: 16),
                      ),
                    ),
                    Text(
                      '${cartItem.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () =>
                          ref.read(cartProvider.notifier).increment(item.id),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Icon(Icons.add, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildVendorSection(CartState cartState) {
    final zoneId = cartState.zoneId!;
    final vendorsAsync = ref.watch(vendorsByZoneProvider(zoneId));
    final cartVendorId = cartState.vendorId;

    return vendorsAsync.when(
      loading: () => Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (vendors) {
        Vendor? vendor;
        if (cartVendorId != null && vendors.isNotEmpty) {
          vendor = vendors.cast<Vendor?>().firstWhere(
            (v) => v!.id == cartVendorId,
            orElse: () => null,
          );
        }
        vendor ??= vendors.isNotEmpty ? vendors.first : null;
        if (vendor == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade200,
                  image: vendor.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(vendor.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: vendor.imageUrl == null
                    ? const Icon(Icons.store, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      vendor.name,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (vendor.deliveryTime != null) ...[
                          Icon(
                            Icons.access_time,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            vendor.deliveryTime!,
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Icon(
                          Icons.delivery_dining,
                          size: 13,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        AppText(
                          Formatters.formatNaira(vendor.deliveryFeeNaira),
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, color: Colors.grey.shade400, fontSize: 14),
        AppText(
          value,
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }
}

// ─── Payment bottom sheet ────────────────────────────────────────────────────

class _PaymentBottomSheet extends StatefulWidget {
  final String selectedPaymentMethod;
  final double totalAmount;
  final ValueChanged<String> onMethodChanged;
  final Future<void> Function() onConfirm;

  const _PaymentBottomSheet({
    required this.selectedPaymentMethod,
    required this.totalAmount,
    required this.onMethodChanged,
    required this.onConfirm,
  });

  @override
  State<_PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<_PaymentBottomSheet> {
  late String _selected;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedPaymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPad + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
            'Payment Method',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          AppText(
            'How would you like to pay?',
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 20),
          _buildOption(
            value: 'PAYSTACK',
            title: 'Card / Bank Transfer',
            subtitle: 'Pay securely via Paystack',
            icon: Icons.credit_card_rounded,
          ),
          const SizedBox(height: 10),
          _buildOption(
            value: 'WALLET',
            title: 'Wallet',
            subtitle: 'Use your DropX wallet balance',
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 10),
          _buildOption(
            value: 'GENERATE_LINK',
            title: 'Payment Link',
            subtitle: 'Share a link for someone else to pay',
            icon: Icons.link_rounded,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      try {
                        await widget.onConfirm();
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                disabledBackgroundColor: AppColors.primaryOrange.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : AppText(
                      'Confirm & Pay ${Formatters.formatNaira(widget.totalAmount)}',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selected == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selected = value);
        widget.onMethodChanged(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange.withValues(alpha: 0.07)
              : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryOrange.withValues(alpha: 0.12)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.primaryOrange
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isSelected
                        ? AppColors.primaryOrange
                        : Colors.black87,
                  ),
                  const SizedBox(height: 2),
                  AppText(subtitle, fontSize: 12, color: Colors.grey.shade500),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryOrange,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Top-up bottom sheet ────────────────────────────────────────────────────

class _TopupBottomSheet extends ConsumerStatefulWidget {
  final double totalAmount;
  final double currentBalance;

  const _TopupBottomSheet({
    required this.totalAmount,
    required this.currentBalance,
  });

  @override
  ConsumerState<_TopupBottomSheet> createState() => _TopupBottomSheetState();
}

class _TopupBottomSheetState extends ConsumerState<_TopupBottomSheet> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _startTopup() async {
    final amountText = _amountController.text.trim();
    final amountNaira = double.tryParse(amountText);

    if (amountNaira == null || amountNaira < 1000) {
      AppToast.showError(context, 'Minimum top-up amount is ₦1000');
      return;
    }

    final session = ref.read(sessionServiceProvider);
    final email = session.email;

    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const AppText('Email Required', fontWeight: FontWeight.bold),
          content: const AppText(
            'Paystack requires an email to process payments. Please update your profile with your email address and try again.',
          ),
          actions: [
            TextButton(
              onPressed: () => AppNavigator.pop(ctx),
              child: const AppText(
                'OK',
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final walletRepo = ref.read(walletRepositoryProvider);
      final amountKobo = (amountNaira * 100).round();

      final result = await walletRepo.initializeTopup(
        WalletTopupInitializeRequest(amountKobo: amountKobo, payerEmail: email),
      );

      if (!mounted) return;

      Navigator.of(context).pop(<String, String>{
        'authorizationUrl': result.authorizationUrl,
        'reference': result.reference,
        'paymentAttemptId': result.paymentAttemptId,
      });
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Top-up failed: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPad + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
            'Top Up Wallet',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          AppText(
            'Your wallet balance is low. Top up to continue with payment.',
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Current Balance',
                  fontSize: 14,
                  color: AppColors.slate500,
                ),
                AppText(
                  Formatters.formatNaira(widget.currentBalance),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const AppText(
            'Enter Amount',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.slate500,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: '₦ ',
              prefixStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade300,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          const AppText(
            'Minimum ₦1000',
            fontSize: 12,
            color: AppColors.slate400,
          ),
          const SizedBox(height: 16),
          // Quick amount chips
          Wrap(
            spacing: 8,
            children: [1000, 2000, 5000].map((amount) {
              return ActionChip(
                label: AppText(
                  '₦$amount',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryOrange,
                ),
                backgroundColor: AppColors.primaryOrange.withValues(
                  alpha: 0.08,
                ),
                side: BorderSide(
                  color: AppColors.primaryOrange.withValues(alpha: 0.3),
                ),
                onPressed: () {
                  _amountController.text = amount.toString();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _startTopup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                disabledBackgroundColor: AppColors.primaryOrange.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const AppText(
                      'Top Up & Continue',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
