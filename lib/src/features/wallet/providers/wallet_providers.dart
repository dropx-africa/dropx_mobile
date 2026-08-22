import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/wallet/data/wallet_repository.dart';
import 'package:dropx_mobile/src/features/wallet/data/remote_wallet_repository.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_balance_response.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_ledger_response.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return RemoteWalletRepository(ref.watch(apiClientProvider));
});

final walletBalanceProvider = FutureProvider<WalletBalance>((ref) {
  return ref.watch(walletRepositoryProvider).getBalance();
});

final walletLedgerProvider = FutureProvider<WalletLedgerData>((ref) {
  return ref.watch(walletRepositoryProvider).getLedger();
});

// Plain state, not derived from [walletBalanceProvider] via `ref.watch` —
// every writer here already refetches walletBalanceProvider and assigns the
// result explicitly, so watching it too just means an unrelated rebuild of
// walletBalanceProvider elsewhere silently resets this back to a stale value.
final walletBalanceKoboProvider = StateProvider<int>((ref) => 0);
