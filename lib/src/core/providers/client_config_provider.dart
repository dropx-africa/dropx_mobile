import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/models/client_config.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/utils/app_log.dart';

/// Fetches and caches the runtime client configuration from the backend.
///
/// - Auto-fetches on first use.
/// - Falls back to [ClientConfig.defaults] on network failure so the app stays
///   functional even when the config endpoint is temporarily unreachable.
/// - Call [ClientConfigNotifier.refresh] to re-fetch (e.g. on pull-to-refresh
///   or when returning from a maintenance screen).
class ClientConfigNotifier extends AsyncNotifier<ClientConfig> {
  @override
  Future<ClientConfig> build() => _fetch();

  Future<ClientConfig> _fetch() async {
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get<Map<String, dynamic>>(
        ApiEndpoints.clientConfig,
        queryParams: {'app': 'customer'},
        fromJson: (json) => json as Map<String, dynamic>,
      );
      final config = ClientConfig.fromJson(response.data);
      AppLog.d('[ClientConfig] fetched: mode=${config.maintenanceMode} groupOrders=${config.groupOrdersEnabled}');
      return config;
    } catch (e) {
      AppLog.e('[ClientConfig] fetch failed — using defaults', e.toString());
      return ClientConfig.defaults;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final clientConfigProvider =
    AsyncNotifierProvider<ClientConfigNotifier, ClientConfig>(
  ClientConfigNotifier.new,
);

/// Convenience synchronous accessor — returns [ClientConfig.defaults] while
/// loading or on error. Use this in widgets that cannot await.
extension ClientConfigRef on WidgetRef {
  ClientConfig get clientConfig =>
      watch(clientConfigProvider).valueOrNull ?? ClientConfig.defaults;
}

extension ClientConfigProviderRef on Ref {
  ClientConfig get clientConfig =>
      read(clientConfigProvider).valueOrNull ?? ClientConfig.defaults;
}
