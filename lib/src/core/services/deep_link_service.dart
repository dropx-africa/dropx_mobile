import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:dropx_mobile/src/route/page.dart';

/// Handles incoming deep links (`dropxmobile://open/<path>` and, once a
/// verified web domain exists, `https://<domain>/<path>`) and routes them
/// to the matching named route.
///
/// Guarded routes (tracking, wallet, support, account) still go through
/// [RequireAuthGuard] at the route level, so a guest tapping a shared link
/// gets the sign-up sheet rather than the raw screen.
class DeepLinkService {
  DeepLinkService({required GlobalKey<NavigatorState> navigatorKey})
    : _navigatorKey = navigatorKey;

  final GlobalKey<NavigatorState> _navigatorKey;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  Future<void> start() async {
    if (kIsWeb) return;

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _handleUri(initial);
    } catch (_) {
      // No initial link, or platform doesn't support it — ignore.
    }

    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
  }

  void _handleUri(Uri uri) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    final path = _normalizedPath(uri);
    if (path == null) return;

    if (path.startsWith('/tracking/')) {
      final orderId = path.substring('/tracking/'.length);
      if (orderId.isNotEmpty) {
        navigator.pushNamed(
          AppRoute.orderTracking,
          arguments: {'orderId': orderId},
        );
      }
      return;
    }

    if (path.startsWith('/parcel/')) {
      final parcelId = path.substring('/parcel/'.length);
      if (parcelId.isNotEmpty) {
        navigator.pushNamed(
          AppRoute.parcelTracking,
          arguments: {'parcelId': parcelId},
        );
      }
      return;
    }

    if (path.startsWith('/group-order/invite/')) {
      final token = path.substring('/group-order/invite/'.length);
      if (token.isNotEmpty) {
        navigator.pushNamed(
          AppRoute.joinGroupOrder,
          arguments: {'token': token},
        );
      }
      return;
    }

    if (path.startsWith('/support/tickets/')) {
      final ticketId = path.substring('/support/tickets/'.length);
      if (ticketId.isNotEmpty) {
        navigator.pushNamed(
          AppRoute.supportTicketDetail,
          arguments: {'ticketId': ticketId},
        );
      }
      return;
    }
    if (path == '/support') {
      navigator.pushNamed(AppRoute.supportTickets);
      return;
    }

    if (path == '/wallet') {
      navigator.pushNamed(AppRoute.walletTopup);
      return;
    }

    if (path == '/account') {
      navigator.pushNamed(AppRoute.editProfile);
      return;
    }

    if (path.startsWith('/vendor/')) {
      final vendorId = path.substring('/vendor/'.length);
      if (vendorId.isNotEmpty) {
        navigator.pushNamed(
          AppRoute.vendorMenu,
          arguments: {'vendorId': vendorId},
        );
      }
      return;
    }

    if (path.startsWith('/pay-link/')) {
      final token = path.substring('/pay-link/'.length);
      if (token.isNotEmpty) {
        navigator.pushNamed(AppRoute.payLink, arguments: {'token': token});
      }
      return;
    }
  }

  /// Normalizes both `dropxmobile://open/<path>` and (once verified)
  /// `https://<domain>/<path>` into a single leading-slash path.
  String? _normalizedPath(Uri uri) {
    final scheme = uri.scheme.toLowerCase();

    if (scheme == 'dropxmobile') {
      if (uri.host.toLowerCase() == 'open') {
        return uri.path.isEmpty ? null : uri.path;
      }
      // dropxmobile://tracking/123 style — treat host as the first segment.
      final rest = uri.path.isEmpty ? '' : uri.path;
      return '/${uri.host}$rest';
    }

    if (scheme == 'https' || scheme == 'http') {
      return uri.path.isEmpty ? null : uri.path;
    }

    return null;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
