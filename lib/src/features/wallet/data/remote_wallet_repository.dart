import 'package:flutter/foundation.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_balance_response.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_ledger_response.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_topup_initialize_request.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_topup_initialize_response.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_topup_verify_request.dart';
import 'package:dropx_mobile/src/features/wallet/data/dto/wallet_topup_verify_response.dart';
import 'package:dropx_mobile/src/features/wallet/data/wallet_repository.dart';

class RemoteWalletRepository implements WalletRepository {
  final ApiClient _apiClient;

  RemoteWalletRepository(this._apiClient);

  @override
  Future<WalletBalance> getBalance() async {
    debugPrint(
      '🔵 [WALLET-API] GET ${ApiEndpoints.baseUrl}${ApiEndpoints.wallet}',
    );
    final response = await _apiClient.get<WalletBalance>(
      ApiEndpoints.wallet,
      fromJson: (json) =>
          WalletBalance.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [WALLET-API] GET /me/wallet → balance=${response.data.availableBalanceKobo}',
    );
    return response.data;
  }

  @override
  Future<WalletLedgerData> getLedger({String? cursor}) async {
    final path = cursor != null
        ? '${ApiEndpoints.walletLedger}?cursor=$cursor'
        : ApiEndpoints.walletLedger;
    debugPrint('🔵 [WALLET-API] GET ${ApiEndpoints.baseUrl}$path');
    final response = await _apiClient.get<WalletLedgerData>(
      path,
      fromJson: (json) =>
          WalletLedgerData.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [WALLET-API] GET /me/wallet/ledger → ${response.data.entries.length} entries',
    );
    return response.data;
  }

  @override
  Future<WalletTopupInitializeData> initializeTopup(
    WalletTopupInitializeRequest request,
  ) async {
    final body = request.toJson();
    debugPrint(
      '🟡 [WALLET-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.walletTopupInitialize}',
    );
    debugPrint('   📦 Body: $body');
    final response = await _apiClient.post<WalletTopupInitializeData>(
      ApiEndpoints.walletTopupInitialize,
      data: body,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          WalletTopupInitializeData.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [WALLET-API] POST /me/wallet/topup/initialize → ref=${response.data.reference}',
    );
    return response.data;
  }

  @override
  Future<WalletTopupVerifyData> verifyTopup(
    WalletTopupVerifyRequest request,
  ) async {
    final body = request.toJson();
    debugPrint(
      '🟡 [WALLET-API] POST ${ApiEndpoints.baseUrl}${ApiEndpoints.walletTopupVerify}',
    );
    debugPrint('   📦 Body: $body');
    final response = await _apiClient.post<WalletTopupVerifyData>(
      ApiEndpoints.walletTopupVerify,
      data: body,
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          WalletTopupVerifyData.fromJson(json as Map<String, dynamic>),
    );
    debugPrint(
      '✅ [WALLET-API] POST /me/wallet/topup/verify → verified=${response.data.verified}',
    );
    return response.data;
  }
}
