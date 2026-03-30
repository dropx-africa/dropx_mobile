import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';

/// A circular back button. Defaults to [AppNavigator.pop].
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color iconColor;
  final Color backgroundColor;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.iconColor = Colors.black,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: backgroundColor,
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: iconColor),
        onPressed: onPressed ?? () => AppNavigator.pop(context),
      ),
    );
  }
}
