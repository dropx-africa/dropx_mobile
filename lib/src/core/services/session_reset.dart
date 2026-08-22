import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/features/profile/providers/profile_provider.dart';
import 'package:dropx_mobile/src/features/profile/providers/notification_providers.dart';
import 'package:dropx_mobile/src/features/wallet/providers/wallet_providers.dart';
import 'package:dropx_mobile/src/features/order/providers/order_providers.dart';
import 'package:dropx_mobile/src/features/parcel/providers/parcel_providers.dart';
import 'package:dropx_mobile/src/features/cart/providers/cart_provider.dart';
import 'package:dropx_mobile/src/features/home/providers/home_feed_providers.dart';

/// Clears every provider that holds data scoped to a specific logged-in
/// user. Riverpod's ProviderScope lives above navigation, so logging out
/// (or dropping into guest mode) never clears cached provider state on its
/// own — without this, the next session (another account, or guest) can
/// still see the previous user's profile/wallet/orders/cart in memory, or
/// crash when code assumes a field that's only present for an authenticated
/// user.
///
/// Call this right after `session.clearSession()` / `session.saveGuestMode()`
/// and before navigating away.
void clearUserScopedProviders(WidgetRef ref) {
  ref.invalidate(profileNotifierProvider);
  ref.invalidate(notificationsFutureProvider);
  ref.invalidate(walletBalanceProvider);
  ref.invalidate(walletLedgerProvider);
  ref.invalidate(ordersProvider);
  ref.invalidate(parcelsProvider);
  ref.invalidate(cartProvider);
  ref.invalidate(homeFeedProvider);
  ref.invalidate(searchProvider);
}
