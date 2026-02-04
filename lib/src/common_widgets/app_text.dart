import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

class AppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;

  const AppText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? AppColors.darkBackground,
        decoration: decoration,
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;

  const AppHeader(this.text, {super.key, this.color, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: color ?? AppColors.darkBackground,
      textAlign: textAlign,
    );
  }
}

class AppSubText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final double? fontSize;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppSubText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.fontSize,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      fontSize: fontSize ?? 14,
      fontWeight: FontWeight.normal,
      color: color ?? AppColors.slate500,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
