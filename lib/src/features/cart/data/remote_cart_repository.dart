import 'package:flutter/foundation.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/cart/data/cart_repository.dart';
import 'package:dropx_mobile/src/features/cart/data/dto/cart_dto.dart';

class RemoteCartRepository implements CartRepository {
  final ApiClient _apiClient;

  RemoteCartRepository(this._apiClient);

  @override
  Future<ServerCartData> getCart() async {
    final response = await _apiClient.get<ServerCartData>(
      ApiEndpoints.cart,
      fromJson: (json) =>
          ServerCartData.fromJson(json as Map<String, dynamic>),
    );
    debugPrint('✅ [CART-API] GET /me/cart → ${response.data.items.length} items');
    return response.data;
  }

  @override
  Future<void> syncCart(CartSyncDto dto) async {
    await _apiClient.patch<void>(
      ApiEndpoints.cart,
      data: dto.toJson(),
      headers: ApiClient.traceHeaders(),
      fromJson: (_) {},
    );
    debugPrint('✅ [CART-API] PATCH /me/cart synced');
  }

  @override
  Future<void> clearCart() async {
    await _apiClient.patch<void>(
      ApiEndpoints.cartClear,
      data: {},
      headers: ApiClient.traceHeaders(),
      fromJson: (_) {},
    );
    debugPrint('✅ [CART-API] PATCH /me/cart/clear');
  }
}
