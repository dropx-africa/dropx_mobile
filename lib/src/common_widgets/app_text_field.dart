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

  const AppTextField({
    super.key,
    this.hintText,
    this.controller,
    this.isPhone = false,
    this.onPhoneChanged,
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

    if (isPhone) {
      return IntlPhoneField(
        controller:
            controller, // Note: IntlPhoneField usually manages its own text, but controller can be used for initial value sometimes or reading text.
        // However, usually onChanged returns full object.
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: border,
          enabledBorder: border,
          focusedBorder: focusedBorder,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          prefixIcon: const Icon(
            Icons.phone_android,
            color: AppColors.slate400,
          ),
          hintText: hintText,
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
        onChanged: onPhoneChanged,
      );
    }

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintText: hintText,
      ),
    );
  }
}
