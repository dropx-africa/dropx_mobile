import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/features/group/data/dto/group_order_models.dart';
import 'package:dropx_mobile/src/features/group/data/group_order_repository.dart';
import 'package:flutter/material.dart';

class RemoteGroupOrderRepository implements GroupOrderRepository {
  final ApiClient _apiClient;

  RemoteGroupOrderRepository(this._apiClient);

  // Header key required by the backend for all participant-scoped operations
  static const _participantHeader = 'X-Group-Participant-Token';

  @override
  Future<CreateGroupOrderResponse> createGroupOrder(String vendorId) async {
    final response = await _apiClient.post<CreateGroupOrderResponse>(
      ApiEndpoints.groupOrders,
      data: {'vendor_id': vendorId},
      headers: ApiClient.traceHeaders(),
      fromJson: (json) => CreateGroupOrderResponse.fromJson(
        json as Map<String, dynamic>,
      ),
    );
    return response.data;
  }

  @override
  Future<GroupOrder> getGroupOrder(
      String groupOrderId,
      String participantToken,
      ) async {
    final response = await _apiClient.get<GroupOrder>(
      ApiEndpoints.groupOrderById(groupOrderId),
      headers: {_participantHeader: participantToken},
      fromJson: (json) => GroupOrder.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<GroupOrderInvitePreview> previewInvite(String token) async {
    final response = await _apiClient.get<GroupOrderInvitePreview>(
      ApiEndpoints.groupOrderInvite(token),
      fromJson: (json) =>
          GroupOrderInvitePreview.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<JoinGroupOrderResponse> joinGroupOrder(
      String token,
      String displayName,
      ) async {
    final response = await _apiClient.post<JoinGroupOrderResponse>(
      ApiEndpoints.groupOrderJoin(token),
      data: {'display_name': displayName},
      headers: ApiClient.traceHeaders(),
      fromJson: (json) =>
          JoinGroupOrderResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<void> addItem(
      String groupOrderId,
      String participantToken, {
        required String itemId,
        required int quantity,
        required String itemName,
        required double unitPriceKobo,
        String? note,
        Map<String, dynamic>? configuration,
      }) async {
    // Generate a line_key based on item ID and configuration
    final lineKey = _generateLineKey(itemId, configuration);

    // Build the item object as expected by the API
    final itemObject = {
      'item_id': itemId,
      'name': itemName,
      'price_kobo': unitPriceKobo.toInt(),
      // Add any other fields the API expects (vendor_id, category, etc.)
      // You may need to get these from somewhere
    };

    final body = {
      'line_key': lineKey,
      'item': itemObject,
      'quantity': quantity,
      if (configuration != null && configuration.isNotEmpty)
        'configuration': configuration,
      if (note != null && note.isNotEmpty)
        'note': note,
    };

    await _apiClient.post<Map>(
      ApiEndpoints.groupOrderItems(groupOrderId),
      data: body,
      headers: {
        _participantHeader: participantToken,
        ...ApiClient.traceHeaders(),
      },
      fromJson: (json) => json as Map,
    );
  }

  String _generateLineKey(String itemId, Map<String, dynamic>? configuration) {
    final parts = <String>[itemId];
    if (configuration != null) {
      // Check for selected_variant in the configuration
      if (configuration.containsKey('selected_variant') && configuration['selected_variant'] != null) {
        final variant = configuration['selected_variant'] as Map<String, dynamic>;
        if (variant.containsKey('variant_id')) {
          parts.add(variant['variant_id'] as String);
        }
      }
      // Check for selected_addons in the configuration
      if (configuration.containsKey('selected_addons') && configuration['selected_addons'] != null) {
        final addons = configuration['selected_addons'] as List<dynamic>;
        for (final addon in addons) {
          final addonMap = addon as Map<String, dynamic>;
          if (addonMap.containsKey('addon_id')) {
            parts.add(addonMap['addon_id'] as String);
          }
        }
      }
    }
    return parts.join('::');
  }

  @override
  Future<void> updateItem(
      String groupOrderId,
      String participantToken,
      String groupOrderItemId, {
        required int quantity,
        String? note,
      }) async {
    await _apiClient.patch<Map>(
      ApiEndpoints.groupOrderItem(groupOrderId, groupOrderItemId),
      data: {
        'quantity': quantity,
        if (note != null) 'note': note,
      },
      headers: {
        _participantHeader: participantToken,
        ...ApiClient.traceHeaders(),
      },
      fromJson: (json) => json as Map,
    );
  }

  @override
  Future<void> removeItem(
      String groupOrderId,
      String participantToken,
      String groupOrderItemId,
      ) async {
    await _apiClient.delete(
      ApiEndpoints.groupOrderItem(groupOrderId, groupOrderItemId),
      headers: {
        _participantHeader: participantToken,
        ...ApiClient.traceHeaders(),
      },
    );
  }

  @override
  Future<void> lockGroupOrder(
      String groupOrderId,
      String participantToken,
      ) async {
    await _apiClient.post<Map>(
      ApiEndpoints.groupOrderLock(groupOrderId),
      data: {},
      headers: {
        _participantHeader: participantToken,
        ...ApiClient.traceHeaders(),
      },
      fromJson: (json) => json as Map,
    );
  }

  @override
  Future<GroupOrderEstimate> estimate(
      String groupOrderId,
      String participantToken, {
        required Map<String, dynamic> body,
      }) async {
    final apiResponse = await _apiClient.post<Map>(
      ApiEndpoints.groupOrderEstimate(groupOrderId),
      data: body,
      headers: {
        _participantHeader: participantToken,
        ...ApiClient.traceHeaders(),
      },
      fromJson: (json) => json as Map,
    );

    // Print the FULL response
    print('📊 Complete estimate response: ${apiResponse.data}');
    print('📊 Response keys: ${(apiResponse.data).keys}');

    // Try to find where the estimate data is
    final responseData = apiResponse.data as Map<String, dynamic>;

    // Check if the estimate data is nested
    if (responseData.containsKey('estimate')) {
      print('📊 Found estimate field');
      return GroupOrderEstimate.fromJson(responseData['estimate'] as Map<String, dynamic>);
    } else if (responseData.containsKey('group_order') &&
        responseData['group_order'].containsKey('estimate')) {
      print('📊 Found estimate inside group_order');
      return GroupOrderEstimate.fromJson(responseData['group_order']['estimate'] as Map<String, dynamic>);
    } else {
      // Maybe the response IS the estimate
      print('📊 Using response as estimate');
      return GroupOrderEstimate.fromJson(responseData);
    }
  }

  @override
  Future<GroupOrderCheckoutResponse> checkout(
      String groupOrderId,
      String participantToken, {
        required Map<String, dynamic> body,
      }) async {
    final apiResponse = await _apiClient.post<Map>(
      ApiEndpoints.groupOrderCheckout(groupOrderId),
      data: body, // Send the delivery address data
      headers: {
        _participantHeader: participantToken,
        ...ApiClient.traceHeaders(),
      },
      fromJson: (json) => json as Map,
    );

    return GroupOrderCheckoutResponse.fromJson(apiResponse.data as Map<String, dynamic>);
  }

  /// SSE stream — yields raw event data strings as they arrive.
  /// The provider layer parses these and triggers a room reload.
  /// Falls back to polling when SSE is unavailable.
  @override
  Stream<String> roomEvents(
      String groupOrderId,
      String participantToken,
      ) {
    return _apiClient
        .sseStream(
      ApiEndpoints.groupOrderEvents(groupOrderId),
      headers: {_participantHeader: participantToken},
    )
        .map((event) {
      debugPrint('📡 [GROUP-SSE-RAW] type=${event.type} data=${event.data}');
      return event;
    })
        .where((event) => event.data.isNotEmpty)
        .map((event) => event.data);
  }
}