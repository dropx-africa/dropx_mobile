import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/auth/presentation/sign_up_to_order_sheet.dart';

/// Wraps a route's screen so guests can't reach it directly (e.g. via a
/// pushed named route that bypasses the tab-level guest gate). Pops the
/// route and shows the sign-up sheet instead of building [child].
class RequireAuthGuard extends ConsumerStatefulWidget {
  final Widget child;

  const RequireAuthGuard({super.key, required this.child});

  @override
  ConsumerState<RequireAuthGuard> createState() => _RequireAuthGuardState();
}

class _RequireAuthGuardState extends ConsumerState<RequireAuthGuard> {
  bool _handled = false;

  void _handleGuestAccess() {
    if (_handled) return;
    _handled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const SignUpToOrderSheet(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(sessionServiceProvider).isGuest;
    if (isGuest) {
      _handleGuestAccess();
      return const Scaffold(body: SizedBox.shrink());
    }
    return widget.child;
  }
}
