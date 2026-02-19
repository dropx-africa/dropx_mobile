import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/route/page.dart';

enum OrderType { parcel, retail, pharmacy }

class GenericOrderScreen extends StatefulWidget {
  final OrderType orderType;
  final String? preFilledItem; // For "Order Now" from Poll
  final int? quantity;
  final bool isGroupOrder;

  const GenericOrderScreen({
    super.key,
    required this.orderType,
    this.preFilledItem,
    this.quantity,
    this.isGroupOrder = false,
  });

  @override
  State<GenericOrderScreen> createState() => _GenericOrderScreenState();
}

class _GenericOrderScreenState extends State<GenericOrderScreen> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _recipientPhoneController =
      TextEditingController();
  final TextEditingController _parcelValueController = TextEditingController();

  // State
  String _selectedParcelType = "Document"; // Default for Parcel
  String _paymentMethod = "Card / Transfer / USSD";

  @override
  void initState() {
    super.initState();
    if (widget.preFilledItem != null) {
      if (widget.isGroupOrder && widget.quantity != null) {
        _detailsController.text =
            "Group Order: ${widget.quantity}x ${widget.preFilledItem}";
      } else {
        _detailsController.text = "Order: ${widget.preFilledItem}";
      }
    }
    // Set default addresses for demo
    _pickupController.text = "12 Herbert Macaulay Way, Yaba";
    _dropoffController.text = "24 Alagomeji Rd, Yaba";
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _detailsController.dispose();
    _recipientPhoneController.dispose();
    _parcelValueController.dispose();
    super.dispose();
  }

  String get _title {
    if (widget.isGroupOrder) {
      return "Group Order";
    }
    switch (widget.orderType) {
      case OrderType.parcel:
        return "Send Parcel";
      case OrderType.retail:
        return "Retail Request";
      case OrderType.pharmacy:
        return "Pharmacy Run";
    }
  }

  String get _pickupLabel {
    switch (widget.orderType) {
      case OrderType.parcel:
        return "Pickup Location";
      case OrderType.retail:
        return "Store Location";
      case OrderType.pharmacy:
        return "Pharmacy Location";
    }
  }

  // Helper to build section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppText(title, fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  // Helper for Address Inputs
  Widget _buildAddressInput(
    String label,
    TextEditingController controller,
    String placeholder, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(label),
        TextFormField(
          controller: controller,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppText(_title, fontSize: 18, fontWeight: FontWeight.bold),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Pickup & Dropoff
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildAddressInput(
                            _pickupLabel,
                            _pickupController,
                            "Search address...",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a pickup address';
                              }
                              if (value.trim().length < 5) {
                                return 'Address must be at least 5 characters';
                              }
                              return null;
                            },
                          ),
                          // Additional field for Pickup (e.g. Landmark)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Landmark / Instructions (Optional)",
                                hintStyle: TextStyle(
                                  color: AppColors.slate400,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildAddressInput(
                            "Dropoff Location",
                            _dropoffController,
                            "Search address...",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a dropoff address';
                              }
                              if (value.trim().length < 5) {
                                return 'Address must be at least 5 characters';
                              }
                              return null;
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Landmark / Instructions (Optional)",
                                hintStyle: TextStyle(
                                  color: AppColors.slate400,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. Item Details
                    _buildSectionHeader(
                      widget.orderType == OrderType.parcel
                          ? "Parcel Details"
                          : "Order Details",
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Parcel Type Selector
                          if (widget.orderType == OrderType.parcel) ...[
                            Row(
                              children: [
                                _buildParcelTypeOption(
                                  "Document",
                                  Icons.description_outlined,
                                ),
                                const SizedBox(width: 12),
                                _buildParcelTypeOption(
                                  "Small Box",
                                  Icons.inventory_2_outlined,
                                ),
                                const SizedBox(width: 12),
                                _buildParcelTypeOption(
                                  "Fragile",
                                  Icons.broken_image_outlined,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _parcelValueController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter the parcel value';
                                }
                                if (double.tryParse(value.trim()) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                labelText: "Parcel Value (₦)",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ] else ...[
                            // Retail / Pharmacy Input
                            TextField(
                              controller: _detailsController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: widget.orderType == OrderType.pharmacy
                                    ? "List required medications..."
                                    : "List items to buy...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _recipientPhoneController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a phone number';
                              }
                              final digits = value.replaceAll(
                                RegExp(r'[^0-9]'),
                                '',
                              );
                              if (digits.length < 10 || digits.length > 13) {
                                return 'Phone number must be 10-13 digits';
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText: "Call recipient before arrival",
                              hintText: "Phone Number",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3. Payment Method
                    _buildSectionHeader("Payment Method"),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildPaymentRadio("Card / Transfer / USSD"),
                          const Divider(height: 1),
                          _buildPaymentRadio("DropX Wallet"),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 300,
                    ), // Spacing for bottom sheet and scrolling
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Sticky Bottom Sheet (Hidden when keyboard is open)
      bottomSheet: MediaQuery.of(context).viewInsets.bottom > 0
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), // Dark Background
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Info Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        AppText(
                          "Estimated ETA",
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                        AppText(
                          "35-45 min",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        AppText(
                          "Delivery Fee",
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                        AppText(
                          "₦700",
                          color: Color(0xFFCBD5E1),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        AppText(
                          "Service Fee",
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                        AppText(
                          "₦200",
                          color: Color(0xFFCBD5E1),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        AppText(
                          "Total",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        AppText(
                          "₦900",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Navigate to Tracking
                            Navigator.pushNamed(
                              context,
                              AppRoute.orderTracking,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            AppText(
                              _getButtonText(),
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getButtonText() {
    if (widget.isGroupOrder) {
      return "Place Group Order";
    }
    switch (widget.orderType) {
      case OrderType.parcel:
        return "Request Pickup";
      case OrderType.retail:
        return "Place Retail Order";
      case OrderType.pharmacy:
        return "Request Meds";
    }
  }

  Widget _buildParcelTypeOption(String label, IconData icon) {
    bool isSelected = _selectedParcelType == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedParcelType = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryOrange.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryOrange
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryOrange : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 8),
              AppText(
                label,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryOrange
                    : Colors.grey.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentRadio(String value) {
    return RadioListTile<String>(
      value: value,
      groupValue: _paymentMethod,
      onChanged: (val) => setState(() => _paymentMethod = val!),
      activeColor: AppColors.primaryOrange,
      title: AppText(value, fontSize: 14, fontWeight: FontWeight.bold),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
