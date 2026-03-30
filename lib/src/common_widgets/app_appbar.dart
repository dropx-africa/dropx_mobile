import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_back_button.dart';

enum AppAppBarStyle { orange, white }

/// A reusable [SliverAppBar] for use inside [CustomScrollView].
///
/// - [AppAppBarStyle.orange] — pinned orange bar, white title (Featured/Fastest).
/// - [AppAppBarStyle.white]  — pinned white bar, dark title, no leading (Discover).
class AppAppBar extends StatelessWidget {
  final String title;
  final AppAppBarStyle style;
  final bool showBack;
  final List<Widget>? actions;

  const AppAppBar({
    super.key,
    required this.title,
    this.style = AppAppBarStyle.orange,
    this.showBack = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isOrange = style == AppAppBarStyle.orange;
    final titleColor = isOrange ? Colors.white : AppColors.darkBackground;
    final bgColor = isOrange ? AppColors.primaryOrange : Colors.white;

    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: bgColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: AppBackButton(
                iconColor: isOrange ? Colors.white : Colors.black,
                backgroundColor: isOrange
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white,
              ),
            )
          : null,
      title: AppText(
        title,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: titleColor,
      ),
      actions: actions,
    );
  }
}
