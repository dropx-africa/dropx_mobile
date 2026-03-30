import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/cart/providers/cart_provider.dart';
import 'package:dropx_mobile/src/core/utils/formatters.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
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

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isPlacingOrder = false;
  bool _isLoadingEstimate = false;
  String _selectedPaymentMethod = 'PAYSTACK'; // Default to Paystack
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
    debugPrint('🛒 [CART] _loadEstimate() called');
    final cartState = ref.read(cartProvider);

    debugPrint('   vendorId=${cartState.vendorId}');
    debugPrint('   zoneId=${cartState.zoneId}');
    debugPrint('   items.length=${cartState.items.length}');

    if (cartState.vendorId == null ||
        cartState.zoneId == null ||
        cartState.items.isEmpty) {
      debugPrint(
        '   ⚠️ Skipping estimate: missing vendorId/zoneId or empty cart',
      );
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
      debugPrint('   📍 deliveryLat=$deliveryLat, deliveryLng=$deliveryLng');
      debugPrint('   📍 savedAddress=$savedAddress');

      // 1. Save the user's address and get a real address_id.
      debugPrint('🟡 [CART] Step 1: Saving address via POST /me/addresses');
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
        debugPrint('✅ [CART] Address saved → addressId=$deliveryAddressId');
      } catch (e) {
        debugPrint(
          '❌ [CART] Address save FAILED (using fallback address-1): $e',
        );
      }

      // 2. Build estimate items.
      final orderItems = cartState.items.values.map((cartItem) {
        return EstimateOrderItem(
          itemId: cartItem.menuItem.id,
          name: cartItem.menuItem.name,
          qty: cartItem.quantity,
          unitPriceKobo: CurrencyUtils.nairaToKobo(cartItem.menuItem.price),
        );
      }).toList();

      // 3. Call estimate.
      debugPrint('🟡 [CART] Step 2: Calling POST /orders/estimate');
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
        final delFee = CurrencyUtils.koboToNaira(
          int.parse(response.data.deliveryFeeKobo),
        );
        final svcFee = CurrencyUtils.koboToNaira(
          int.parse(response.data.serviceFeeKobo),
        );
        debugPrint(
          '✅ [CART] Estimate received → deliveryFee=₦$delFee, serviceFee=₦$svcFee',
        );
        setState(() {
          _deliveryFee = delFee;
          _serviceFee = svcFee;
        });
      }
    } catch (e, stack) {
      if (mounted) {
        debugPrint('❌ [CART] _loadEstimate FAILED: $e');
        debugPrint('   Stack: $stack');
      }
    } finally {
      if (mounted) setState(() => _isLoadingEstimate = false);
    }
  }

  Future<void> _placeOrder() async {
    debugPrint('🛒 [CART] _placeOrder() called');
    final cartState = ref.read(cartProvider);
    final session = ref.read(sessionServiceProvider);
    final orderRepo = ref.read(orderRepositoryProvider);

    final vendorId = cartState.vendorId;
    final zoneId = cartState.zoneId;
    final deliveryAddress = session.savedAddress;

    debugPrint('   vendorId=$vendorId, zoneId=$zoneId');
    debugPrint('   deliveryAddress=$deliveryAddress');
    debugPrint('   paymentMethod=$_selectedPaymentMethod');

    if (vendorId == null || zoneId == null) {
      debugPrint('   ⚠️ Aborting: missing vendorId or zoneId');
      _showSnackBar('Unable to place order. Please add items from a vendor.');
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      // 1. Build CreateOrderDto from cart items.
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

      // 2. Create the order.
      debugPrint('🟡 [CART] Step 1: Creating order via POST /orders');
      final orderResponse = await orderRepo.createOrder(createDto);
      final orderId = orderResponse.order.orderId;
      debugPrint('✅ [CART] Order created → orderId=$orderId');

      // Determine logic based on selected payment method
      if (_selectedPaymentMethod == 'WALLET') {
        debugPrint(
          '🟡 [CART] Step 2: Placing order with WALLET via POST /orders/$orderId/place',
        );
        final walletDto = PlaceOrderDto(paymentMethod: 'WALLET');
        await orderRepo.placeOrder(orderId, walletDto);
        debugPrint('✅ [CART] Wallet payment successful');

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoute.orderSuccess);
      } else if (_selectedPaymentMethod == 'GENERATE_LINK') {
        final linkDto = GeneratePaymentLinkDto(ttlMinutes: 30);
        final linkResponse = await orderRepo.generatePaymentLink(
          orderId,
          linkDto,
        );

        if (!mounted) return;

        final shareableLink =
            'https://dropxwebapp.vercel.app/pay-link/${linkResponse.token}';

        showDialog(
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Link copied to clipboard!'),
                            ),
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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const AppText(
                  'Close',
                  color: AppColors.grayText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      } else {
        // 3. Initialize payment (Default Paystack)
        final paymentDto = InitializePaymentDto(orderId: orderId);
        final paymentResponse = await orderRepo.initializePayment(paymentDto);

        if (!mounted) return;

        // 4. Navigate to Paystack checkout.
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
    } catch (e, stack) {
      debugPrint('❌ [CART] _placeOrder FAILED: $e');
      debugPrint('   Stack: $stack');
      if (mounted) {
        _showSnackBar('Failed to place order: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
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

    // Fallback: if estimate hasn't loaded a delivery fee yet, use vendor's known fee
    final double vendorDeliveryFee = cartState.zoneId != null
        ? ref
              .watch(vendorsByZoneProvider(cartState.zoneId!))
              .maybeWhen(
                data: (vendors) {
                  final v = vendors.cast<Vendor?>().firstWhere(
                    (v) => v?.id == cartState.vendorId,
                    orElse: () => vendors.isNotEmpty ? vendors.first : null,
                  );
                  return v?.deliveryFee ?? 0.0;
                },
                orElse: () => 0.0,
              )
        : 0.0;
    final double displayDeliveryFee = _deliveryFee > 0
        ? _deliveryFee
        : vendorDeliveryFee;

    // Calculate fees
    final totalAmount = totalPrice + displayDeliveryFee + _serviceFee;

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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  AppText(
                    "Your cart is empty",
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ],
              ),
            ),
          )
        else ...[
          // Vendor Info (fetched via getVendors with zoneId)
          if (cartState.zoneId != null)
            SliverToBoxAdapter(child: _buildVendorSection(cartState)),

          // Address Section
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
                        onTap: () {
                          Navigator.pushNamed(context, AppRoute.manualLocation);
                        },
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

          // Payment Method Selection
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "PAYMENT METHOD",
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethodOption(
                    'PAYSTACK',
                    'Paystack',
                    Icons.credit_card,
                  ),
                  _buildPaymentMethodOption(
                    'WALLET',
                    'Wallet',
                    Icons.account_balance_wallet,
                  ),
                  _buildPaymentMethodOption(
                    'GENERATE_LINK',
                    'Generate Link',
                    Icons.link,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Bill Details (Sticky Footer)
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
                        : Formatters.formatNaira(displayDeliveryFee),
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
                        Formatters.formatNaira(totalAmount),
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isPlacingOrder
                          ? null
                          : () {
                              _placeOrder();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        disabledBackgroundColor: AppColors.primaryOrange
                            .withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isPlacingOrder
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const AppText(
                              "Place Order",
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Image
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
              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        ref.read(cartProvider.notifier).decrement(item.id);
                      },
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
                      onTap: () {
                        ref.read(cartProvider.notifier).increment(item.id);
                      },
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

  /// Fetches vendors by zoneId and displays the matching vendor's info.
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
        // Find the vendor that matches the cart items
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
              // Vendor image
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
                          '₦${(vendor.deliveryFee ?? 0).toInt()}',
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

  Widget _buildPaymentMethodOption(String value, String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryOrange
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                title,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? AppColors.primaryOrange : Colors.black87,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryOrange,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
