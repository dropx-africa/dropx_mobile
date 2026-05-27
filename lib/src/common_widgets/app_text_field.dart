import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final bool isPhone;
  final ValueChanged<PhoneNumber>? onPhoneChanged;
  final String? label;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool readOnly;

  const AppTextField({
    super.key,
    this.hintText,
    this.controller,
    this.isPhone = false,
    this.onPhoneChanged,
    this.label,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkBackground),
    );

    final disabledFillColor = readOnly ? const Color(0xFFEEF0F3) : const Color(0xFFF8FAFC);

    if (isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(height: 8),
          ],
          IntlPhoneField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              filled: true,
              fillColor: disabledFillColor,
              border: border,
              enabledBorder: border,
              focusedBorder: readOnly ? border : focusedBorder,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              hintText: hintText,
              suffixIcon: readOnly
                  ? const Icon(Icons.lock_outline, size: 18, color: AppColors.slate400)
                  : null,
            ),
            initialCountryCode: 'NG',
            disableLengthCheck: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            dropdownIconPosition: IconPosition.trailing,
            flagsButtonPadding: const EdgeInsets.only(left: 10),
            showCountryFlag: true,
            onChanged: readOnly ? null : onPhoneChanged,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.slate500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: readOnly ? null : onChanged,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: disabledFillColor,
            border: border,
            enabledBorder: border,
            focusedBorder: readOnly ? border : focusedBorder,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            hintText: hintText,
            suffixIcon: readOnly
                ? const Icon(Icons.lock_outline, size: 18, color: AppColors.slate400)
                : suffixIcon,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}
