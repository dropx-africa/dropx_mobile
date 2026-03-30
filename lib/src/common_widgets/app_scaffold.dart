import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

/// A base scaffold built on [CustomScrollView] for the entire app.
///
/// Use [children] for normal scrollable screens — they are wrapped in a
/// [SliverToBoxAdapter] with a [Column] so you never need to repeat
/// [CustomScrollView] yourself.
///
/// Use [slivers] when you need full sliver control (e.g. [SliverFillRemaining]
/// for fixed-layout screens like Onboarding, or [SliverGrid] for grids).
///
/// Pass a [SliverAppBar] (e.g. [AppAppBar]) via [appBar] to get a pinned
/// header without extra boilerplate.
///
/// ```dart
/// // Scrollable screen with children
/// AppScaffold(
///   appBar: AppAppBar(title: 'Profile', style: AppAppBarStyle.white),
///   children: [AppHeader('Hello'), AppSpaces.v16, ...],
/// )
///
/// // Fixed-layout screen (no scroll)
/// AppScaffold(
///   slivers: [
///     SliverFillRemaining(
///       hasScrollBody: false,
///       child: SafeArea(child: Column(...)),
///     ),
///   ],
/// )
/// ```
class AppScaffold extends StatelessWidget {
  /// Full sliver control. Use for fixed-layout or advanced scrolling screens.
  final List<Widget>? slivers;

  /// Regular widgets auto-wrapped in [SliverToBoxAdapter] + [Column].
  final List<Widget>? children;

  /// Horizontal (and optional vertical) padding for [children].
  /// Defaults to `EdgeInsets.symmetric(horizontal: 24)`.
  final EdgeInsetsGeometry contentPadding;

  /// Optional sliver widget placed before content — typically [AppAppBar].
  final Widget? appBar;

  /// Scaffold/CustomScrollView background colour.
  final Color backgroundColor;

  /// Whether to wrap the scroll view in [SafeArea] (top only) when no [appBar]
  /// is provided. Set to `false` when [slivers] contain [SliverFillRemaining]
  /// with its own [SafeArea]. Defaults to `true`.
  final bool useSafeArea;

  final ScrollController? controller;
  final ScrollPhysics? physics;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    this.slivers,
    this.children,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 24),
    this.appBar,
    this.backgroundColor = AppColors.white,
    this.useSafeArea = true,
    this.controller,
    this.physics,
    this.floatingActionButton,
  }) : assert(
         slivers != null || children != null,
         'AppScaffold requires either slivers or children.',
       );

  @override
  Widget build(BuildContext context) {
    final scrollView = CustomScrollView(
      controller: controller,
      physics: physics,
      slivers: [
        if (appBar != null) appBar!,
        if (slivers != null)
          ...slivers!
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children!,
              ),
            ),
          ),
      ],
    );

    // When there is no SliverAppBar, the Scaffold body starts behind the
    // status bar. Apply a top SafeArea so content isn't clipped.
    final body = (appBar == null && useSafeArea)
        ? SafeArea(bottom: false, child: scrollView)
        : scrollView;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
