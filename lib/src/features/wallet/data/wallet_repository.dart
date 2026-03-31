import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_balance_response.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_ledger_response.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_topup_initialize_request.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_topup_initialize_response.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_topup_verify_request.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_topup_verify_response.dart';

abstract class WalletRepository {
  Future<WalletBalance> getBalance();

  Future<WalletLedgerData> getLedger({String? cursor});

  Future<WalletTopupInitializeData> initializeTopup(
    WalletTopupInitializeRequest request,
  );

  Future<WalletTopupVerifyData> verifyTopup(WalletTopupVerifyRequest request);
}
