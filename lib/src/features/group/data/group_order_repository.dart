import 'package:dropx_mobile/src/features/group/data/dto/group_order_models.dart';

abstract class GroupOrderRepository {
  /// Create a new group order room. Host must be authenticated.
  Future<CreateGroupOrderResponse> createGroupOrder(String vendorId);

  /// Read the current room state.
  Future<GroupOrder> getGroupOrder(
      String groupOrderId,
      String participantToken,
      );

  /// Preview an invite link before joining.
  Future<GroupOrderInvitePreview> previewInvite(String token);

  /// Join a group order as a participant (can be guest).
  Future<JoinGroupOrderResponse> joinGroupOrder(
      String token,
      String displayName,
      );

  /// Add an item to the shared cart.
  Future<void> addItem(
      String groupOrderId,
      String participantToken, {
        required String itemId,
        required int quantity,
        required String itemName,
        required double unitPriceKobo,
        String? note,
        Map<String, dynamic>? configuration,
      });

  /// Update quantity on an existing line.
  Future<void> updateItem(
      String groupOrderId,
      String participantToken,
      String groupOrderItemId, {
        required int quantity,
        String? note,
      });

  /// Remove a line from the shared cart.
  Future<void> removeItem(
      String groupOrderId,
      String participantToken,
      String groupOrderItemId,
      );

  /// Host locks the room — participants can no longer edit.
  Future<void> lockGroupOrder(
      String groupOrderId,
      String participantToken,
      );

  /// Host unlocks the room — reopens it for editing.
  Future<void> unlockGroupOrder(
      String groupOrderId,
      String participantToken,
      );

  /// Host cancels the group order.
  Future<void> cancelGroupOrder(
      String groupOrderId,
      String participantToken,
      );

  /// Estimate total before checkout.
  Future<GroupOrderEstimate> estimate(
      String groupOrderId,
      String participantToken, {
        required Map<String, dynamic> body,
      });

  /// Host checks out — creates one normal draft order.
  Future<GroupOrderCheckoutResponse> checkout(
      String groupOrderId,
      String participantToken, {
        required Map<String, dynamic> body,
      });

  /// SSE stream for real-time room updates.
  Stream<String> roomEvents(
      String groupOrderId,
      String participantToken,
      );

}