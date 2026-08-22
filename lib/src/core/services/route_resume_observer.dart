import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/core/services/session_service.dart';
import 'package:dropx_mobile/src/route/page.dart';

/// Persists whichever screen the customer is currently on (from a curated
/// allowlist) so a cold app restart can resume there instead of always
/// dropping back to the dashboard.
///
/// Deliberately excludes:
/// - Onboarding/auth screens (login, OTP, password reset, manual location)
///   — already handled by [SessionService.getInitialRoute].
/// - Payment/checkout screens (Paystack/wallet checkout, order success,
///   pay-link) — their URLs and state are time-limited; resuming into a
///   stale checkout would be actively broken.
/// - Group order screens — depend on in-memory session state that doesn't
///   survive a cold restart correctly.
/// - Vendor menu — its `category` argument is an enum that can't round-trip
///   through JSON without extra machinery; safer to just exclude it.
class RouteResumeObserver extends NavigatorObserver {
  RouteResumeObserver(this._session);

  final SessionService _session;

  static const _resumableRoutes = {
    AppRoute.dashboard,
    AppRoute.cart,
    AppRoute.orderTracking,
    AppRoute.receipt,
    AppRoute.transactionDetails,
    AppRoute.notifications,
    AppRoute.walletTopup,
    AppRoute.editProfile,
    AppRoute.contactSync,
    AppRoute.socialFeed,
    AppRoute.preferences,
    AppRoute.notificationSettings,
    AppRoute.supportTickets,
    AppRoute.addressBook,
    AppRoute.supportTicketDetail,
    AppRoute.parcel,
    AppRoute.parcelTracking,
    AppRoute.featuredFood,
    AppRoute.fastestFood,
    AppRoute.featuredRetail,
    AppRoute.fastestRetail,
    AppRoute.about,
    AppRoute.privacy,
    AppRoute.terms,
  };

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _maybeSave(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) _maybeSave(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _maybeSave(newRoute);
  }

  void _maybeSave(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || !_resumableRoutes.contains(name)) return;

    final args = route.settings.arguments;
    String argsJson;
    if (args == null) {
      argsJson = '{}';
    } else if (args is Map) {
      try {
        argsJson = jsonEncode(args);
      } catch (_) {
        // Not safely round-trippable (e.g. contains a non-primitive value)
        // — skip rather than persist something we can't restore correctly.
        return;
      }
    } else {
      return;
    }

    _session.saveLastRoute(name: name, argsJson: argsJson);
  }
}
