import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/core/utils/formatters.dart';
import 'package:dropx_mobile/src/features/location/data/geocode_result.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_quote_request.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_quote_response.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/create_parcel_dto.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/place_parcel_dto.dart';
import 'package:dropx_mobile/src/features/parcel/data/dto/parcel_payment_initialize_dto.dart';
import 'package:dropx_mobile/src/features/parcel/presentation/parcel_address_picker_screen.dart';
import 'package:dropx_mobile/src/features/parcel/providers/parcel_providers.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/utils/currency_utils.dart';

const _parcelTypeApiMap = {
  'Document': 'DOCUMENT',
  'Small Box': 'SMALL_BOX',
  'Fragile': 'FRAGILE',
};

class ParcelScreen extends ConsumerStatefulWidget {
  const ParcelScreen({super.key});

  @override
  ConsumerState<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends ConsumerState<ParcelScreen> {
  final _formKey = GlobalKey<FormState>();

  // Address selections from the map picker
  GeocodeResult? _pickupResult;
  GeocodeResult? _dropoffResult;

  // Sender fields
  final _senderNameCtrl = TextEditingController();
  String _senderPhoneE164 = '';
  bool _senderPhoneValid = false;

  // Recipient fields
  final _recipientNameCtrl = TextEditingController();
  String _recipientPhoneE164 = '';
  bool _recipientPhoneValid = false;

  // Parcel details
  final _parcelValueCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _selectedParcelType = 'Document';
  String _paymentMethod = 'PAYSTACK';
  bool _isUrgent = false;

  bool _isLoadingQuote = false;
  bool _isPlacing = false;
  ParcelQuoteData? _quote;

  @override
  void dispose() {
    _senderNameCtrl.dispose();
    _recipientNameCtrl.dispose();
    _parcelValueCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ─── Address picker ────────────────────────────────────────────────────────

  Future<void> _pickAddress({required bool isPickup}) async {
    final result = await Navigator.push<GeocodeResult>(
      context,
      MaterialPageRoute(
        builder: (_) => ParcelAddressPickerScreen(
          title: isPickup ? 'Pickup Location' : 'Dropoff Location',
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      if (isPickup) {
        _pickupResult = result;
      } else {
        _dropoffResult = result;
      }
      _quote = null; // invalidate quote when address changes
    });
  }

  // ─── Quote ────────────────────────────────────────────────────────────────

  Future<void> _getQuote() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickupResult == null || _dropoffResult == null) {
      AppToast.showError(context, 'Please select pickup and dropoff locations');
      return;
    }
    if (!_senderPhoneValid) {
      AppToast.showError(context, 'Enter a valid sender phone number');
      return;
    }
    if (!_recipientPhoneValid) {
      AppToast.showError(context, 'Enter a valid recipient phone number');
      return;
    }

    final valueNaira = double.tryParse(_parcelValueCtrl.text.trim()) ?? 0;

    setState(() {
      _isLoadingQuote = true;
      _quote = null;
    });

    try {
      final repo = ref.read(parcelRepositoryProvider);
      final quote = await repo.getQuote(
        ParcelQuoteRequest(
          parcelType: _parcelTypeApiMap[_selectedParcelType] ?? 'DOCUMENT',
          pickup: ParcelAddressDto(
            addressLine: _pickupResult!.formattedAddress,
            lat: _pickupResult!.lat,
            lng: _pickupResult!.lng,
          ),
          dropoff: ParcelAddressDto(
            addressLine: _dropoffResult!.formattedAddress,
            lat: _dropoffResult!.lat,
            lng: _dropoffResult!.lng,
          ),
          sender: ParcelContactDto(
            name: _senderNameCtrl.text.trim(),
            phoneE164: _senderPhoneE164,
          ),
          recipient: ParcelContactDto(
            name: _recipientNameCtrl.text.trim(),
            phoneE164: _recipientPhoneE164,
          ),
          declaredValueKobo: CurrencyUtils.nairaToKobo(valueNaira),
          paymentMethod: _paymentMethod,
          notes: _notesCtrl.text.trim().isNotEmpty
              ? _notesCtrl.text.trim()
              : null,
          isUrgent: _isUrgent,
        ),
      );
      if (mounted) setState(() => _quote = quote);
    } catch (e) {
      if (mounted) AppToast.showError(context, 'Could not get quote: $e');
    } finally {
      if (mounted) setState(() => _isLoadingQuote = false);
    }
  }

  // ─── Place ────────────────────────────────────────────────────────────────

  Future<void> _placeOrder() async {
    final quote = _quote;
    if (quote == null) return;
    if (_pickupResult == null || _dropoffResult == null) return;
    if (!_formKey.currentState!.validate()) return;

    final valueNaira = double.tryParse(_parcelValueCtrl.text.trim()) ?? 0;

    setState(() => _isPlacing = true);
    try {
      final repo = ref.read(parcelRepositoryProvider);

      // 1. Create parcel (DRAFT)
      final parcel = await repo.createParcel(
        CreateParcelDto(
          quoteId: quote.quoteId,
          parcelType: _parcelTypeApiMap[_selectedParcelType] ?? 'DOCUMENT',
          pickup: ParcelAddressDto(
            addressLine: _pickupResult!.formattedAddress,
            lat: _pickupResult!.lat,
            lng: _pickupResult!.lng,
          ),
          dropoff: ParcelAddressDto(
            addressLine: _dropoffResult!.formattedAddress,
            lat: _dropoffResult!.lat,
            lng: _dropoffResult!.lng,
          ),
          sender: ParcelContactDto(
            name: _senderNameCtrl.text.trim(),
            phoneE164: _senderPhoneE164,
          ),
          recipient: ParcelContactDto(
            name: _recipientNameCtrl.text.trim(),
            phoneE164: _recipientPhoneE164,
          ),
          declaredValueKobo: CurrencyUtils.nairaToKobo(valueNaira),
          paymentMethod: _paymentMethod,
          notes: _notesCtrl.text.trim().isNotEmpty
              ? _notesCtrl.text.trim()
              : null,
          isUrgent: _isUrgent,
        ),
      );

      if (!mounted) return;

      if (_paymentMethod == 'PAYSTACK') {
        // Paystack: initialize then open checkout.
        // On completion PaystackCheckoutScreen will navigate to parcelTracking.
        final payData = await repo.initializePayment(
          parcel.parcelId,
          const ParcelPaymentInitializeDto(),
        );
        if (!mounted) return;
        AppNavigator.push(
          context,
          AppRoute.paystackCheckout,
          arguments: {
            'authorizationUrl': payData.authorizationUrl,
            'reference': payData.reference,
            'orderId': parcel.parcelId,
            'successRoute': AppRoute.parcelTracking,
            'successArgs': {'parcelId': parcel.parcelId},
          },
        );
      } else if (_paymentMethod == 'GENERATE_LINK') {
        // Generate a shareable payment link.
        final token = await repo.generatePaymentLink(parcel.parcelId);
        if (!mounted) return;
        final shareableLink = 'https://dropxwebapp.vercel.app/pay-link/$token';
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
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
                  'Share this link to complete the payment:',
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
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: shareableLink));
                          AppToast.showSuccess(ctx, 'Link copied!');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const AppText(
                  'Done',
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
        if (!mounted) return;
        AppNavigator.pushAndRemoveAll(
          context,
          AppRoute.parcelTracking,
          arguments: {'parcelId': parcel.parcelId},
        );
      } else {
        // WALLET: place immediately, then go to parcel tracking.
        await repo.placeParcel(
          parcel.parcelId,
          PlaceParcelDto(paymentMethod: _paymentMethod),
        );
        if (!mounted) return;
        AppNavigator.pushAndRemoveAll(
          context,
          AppRoute.parcelTracking,
          arguments: {'parcelId': parcel.parcelId},
        );
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, 'Failed to place order: $e');
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const AppText(
          'Send Parcel',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Addresses ──────────────────────────────────────────
                    _sectionLabel('Pickup & Dropoff'),
                    _card(
                      child: Column(
                        children: [
                          _addressTile(
                            label: 'Pickup Location',
                            icon: Icons.trip_origin,
                            iconColor: Colors.green,
                            result: _pickupResult,
                            onTap: () => _pickAddress(isPickup: true),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Divider(height: 16),
                          ),
                          _addressTile(
                            label: 'Dropoff Location',
                            icon: Icons.location_on,
                            iconColor: AppColors.primaryOrange,
                            result: _dropoffResult,
                            onTap: () => _pickAddress(isPickup: false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Parcel type + value ────────────────────────────────
                    _sectionLabel('Parcel Details'),
                    _card(
                      child: Column(
                        children: [
                          Row(
                            children: _parcelTypeApiMap.keys
                                .map(_typeChip)
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _parcelValueCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _dec('Declared Value (₦)'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter declared value';
                              }
                              if (double.tryParse(v.trim()) == null) {
                                return 'Enter a valid amount';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesCtrl,
                            decoration: _dec('Notes (optional)'),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AppText(
                                'Urgent delivery',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              Switch(
                                value: _isUrgent,
                                activeColor: AppColors.primaryOrange,
                                onChanged: (v) => setState(() {
                                  _isUrgent = v;
                                  _quote = null;
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Sender ─────────────────────────────────────────────
                    _sectionLabel('Sender'),
                    _card(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _senderNameCtrl,
                            decoration: _dec('Sender Name'),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter sender name'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          IntlPhoneField(
                            initialCountryCode: 'NG',
                            decoration: _dec('Sender Phone'),
                            onChanged: (phone) {
                              _senderPhoneE164 = phone.completeNumber;
                              _senderPhoneValid = phone.number.isNotEmpty;
                            },
                            onCountryChanged: (_) {
                              _senderPhoneE164 = '';
                              _senderPhoneValid = false;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Recipient ──────────────────────────────────────────
                    _sectionLabel('Recipient'),
                    _card(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _recipientNameCtrl,
                            decoration: _dec('Recipient Name'),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter recipient name'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          IntlPhoneField(
                            initialCountryCode: 'NG',
                            decoration: _dec('Recipient Phone'),
                            onChanged: (phone) {
                              _recipientPhoneE164 = phone.completeNumber;
                              _recipientPhoneValid = phone.number.isNotEmpty;
                            },
                            onCountryChanged: (_) {
                              _recipientPhoneE164 = '';
                              _recipientPhoneValid = false;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Payment method ─────────────────────────────────────
                    _sectionLabel('Payment Method'),
                    _card(
                      child: Column(
                        children: [
                          _paymentRadio('PAYSTACK', 'Card / Transfer / USSD'),
                          const Divider(height: 1),
                          _paymentRadio('WALLET', 'DropX Wallet'),
                          const Divider(height: 1),
                          _paymentRadio('GENERATE_LINK', 'Generate Payment Link'),
                        ],
                      ),
                    ),

                    // ── Quote result ───────────────────────────────────────
                    if (_quote != null) ...[
                      const SizedBox(height: 16),
                      _buildQuoteCard(_quote!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  // ─── Address tile ──────────────────────────────────────────────────────────

  Widget _addressTile({
    required String label,
    required IconData icon,
    required Color iconColor,
    required GeocodeResult? result,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    label,
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(height: 2),
                  result != null
                      ? AppText(
                          result.formattedAddress,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : AppText(
                          'Tap to select on map',
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      );

  // ─── Quote card ────────────────────────────────────────────────────────────

  Widget _buildQuoteCard(ParcelQuoteData q) {
    final delivery = CurrencyUtils.koboToNaira(q.feeBreakdown.deliveryFeeKobo);
    final insurance =
        CurrencyUtils.koboToNaira(q.feeBreakdown.insuranceFeeKobo);
    final total = CurrencyUtils.koboToNaira(q.feeBreakdown.totalKobo);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Quote',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          if (q.distanceKm != null)
            _quoteRow('Distance', '${q.distanceKm!.toStringAsFixed(1)} km'),
          if (q.etaMinutes != null)
            _quoteRow('ETA', '${q.etaMinutes} mins'),
          _quoteRow('Delivery Fee', Formatters.formatNaira(delivery)),
          _quoteRow('Insurance Fee', Formatters.formatNaira(insurance)),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Total',
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              AppText(
                Formatters.formatNaira(total),
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.primaryOrange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quoteRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, fontSize: 13, color: Colors.grey.shade700),
        AppText(value, fontSize: 13, fontWeight: FontWeight.w600),
      ],
    ),
  );

  // ─── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final hasQuote = _quote != null;
    final totalStr = hasQuote
        ? Formatters.formatNaira(
            CurrencyUtils.koboToNaira(_quote!.feeBreakdown.totalKobo),
          )
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasQuote) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    'Total',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  AppText(
                    totalStr!,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                if (!hasQuote)
                  Expanded(child: _quoteButton())
                else ...[
                  Expanded(flex: 1, child: _requoteButton()),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: _placeButton()),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quoteButton() => SizedBox(
    height: 50,
    child: ElevatedButton(
      onPressed: _isLoadingQuote ? null : _getQuote,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoadingQuote
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF0F172A),
              ),
            )
          : const AppText(
              'Get Quote',
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
    ),
  );

  Widget _requoteButton() => SizedBox(
    height: 50,
    child: OutlinedButton(
      onPressed: _isPlacing ? null : _getQuote,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const AppText('Re-quote', color: Colors.white, fontSize: 13),
    ),
  );

  Widget _placeButton() => SizedBox(
    height: 50,
    child: ElevatedButton(
      onPressed: _isPlacing ? null : _placeOrder,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isPlacing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const AppText(
              'Request Pickup',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
    ),
  );

  // ─── Widget helpers ────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: AppText(text, fontWeight: FontWeight.bold, fontSize: 14),
  );

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
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

  Widget _typeChip(String label) {
    final selected = _selectedParcelType == label;
    const icons = {
      'Document': Icons.description_outlined,
      'Small Box': Icons.inventory_2_outlined,
      'Fragile': Icons.broken_image_outlined,
    };
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedParcelType = label;
          _quote = null;
        }),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryOrange.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primaryOrange : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icons[label] ?? Icons.inventory_outlined,
                size: 22,
                color: selected ? AppColors.primaryOrange : Colors.grey,
              ),
              const SizedBox(height: 4),
              AppText(
                label,
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? AppColors.primaryOrange
                    : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentRadio(String value, String label) => RadioListTile<String>(
    value: value,
    groupValue: _paymentMethod,
    onChanged: (v) => setState(() {
      _paymentMethod = v!;
      _quote = null;
    }),
    activeColor: AppColors.primaryOrange,
    title: AppText(label, fontSize: 14, fontWeight: FontWeight.w500),
    contentPadding: EdgeInsets.zero,
    dense: true,
  );

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primaryOrange),
    ),
  );
}
