
class GroupOrderParticipant {
  final String participantId;
  final String displayName;
  final bool isHost;

  const GroupOrderParticipant({
    required this.participantId,
    required this.displayName,
    required this.isHost,
  });

  factory GroupOrderParticipant.fromJson(Map<String, dynamic> json) {
    return GroupOrderParticipant(
      participantId: json['participant_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'Guest',
      // API uses role:'HOST' not is_host:true
      isHost: json['role'] == 'HOST' || json['is_host'] == true,
    );
  }
}

// ── Group Order Item ─────────────────────────────────────────────────────────

class GroupOrderItem {
  final String groupOrderItemId;
  final String itemId;
  final String participantId;
  final String participantDisplayName;
  final int quantity;
  final String? note;
  final String name;
  final double unitPriceKobo;
  final double totalPriceKobo;

  double get unitPrice => unitPriceKobo / 100;
  double get totalPrice => totalPriceKobo / 100;

  const GroupOrderItem({
    required this.groupOrderItemId,
    required this.itemId,
    required this.participantId,
    required this.participantDisplayName,
    required this.quantity,
    this.note,
    required this.name,
    required this.unitPriceKobo,
    required this.totalPriceKobo,
  });

  factory GroupOrderItem.fromJson(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>? ?? {};
    return GroupOrderItem(
      groupOrderItemId: json['group_order_item_id'] as String? ?? '',
      itemId: json['catalog_item_id'] as String? ?? json['item_id'] as String? ?? '',
      participantId: json['participant_id'] as String? ?? '',
      participantDisplayName: json['participant_display_name'] as String? ?? 'Guest',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      note: json['note'] as String?,
      name: item['name'] as String? ?? '',
      unitPriceKobo: (json['unit_price_kobo'] as num?)?.toDouble() ?? 0,
      totalPriceKobo: (json['line_total_kobo'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ── Group Discount ───────────────────────────────────────────────────────────

class GroupDiscountTier {
  final String key;
  final String label;
  final int peopleWithItems;
  final int discountBps;

  double get discountPercent => discountBps / 100;

  const GroupDiscountTier({
    required this.key,
    required this.label,
    required this.peopleWithItems,
    required this.discountBps,
  });

  factory GroupDiscountTier.fromJson(Map<String, dynamic> json) {
    return GroupDiscountTier(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      peopleWithItems: (json['people_with_items'] as num?)?.toInt() ?? 0,
      discountBps: (json['discount_bps'] as num?)?.toInt() ?? 0,
    );
  }
}

class GroupDiscount {
  final bool enabled;
  final bool eligible;
  final int progressPercent;
  final int peopleNeeded;
  final int peopleWithItems;
  final String message;
  final GroupDiscountTier? nextTier;
  final GroupDiscountTier? currentTier;

  const GroupDiscount({
    required this.enabled,
    required this.eligible,
    required this.progressPercent,
    required this.peopleNeeded,
    required this.peopleWithItems,
    required this.message,
    this.nextTier,
    this.currentTier,
  });

  factory GroupDiscount.fromJson(Map<String, dynamic> json) {
    final nextTierJson = json['next_tier'] as Map<String, dynamic>?;
    final currentTierJson = json['current_tier'] as Map<String, dynamic>?;
    return GroupDiscount(
      enabled: json['enabled'] == true,
      eligible: json['eligible'] == true,
      progressPercent: (json['progress_percent'] as num?)?.toInt() ?? 0,
      peopleNeeded: (json['people_needed'] as num?)?.toInt() ?? 0,
      peopleWithItems: (json['people_with_items'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? '',
      nextTier: nextTierJson != null
          ? GroupDiscountTier.fromJson(nextTierJson)
          : null,
      currentTier: currentTierJson != null
          ? GroupDiscountTier.fromJson(currentTierJson)
          : null,
    );
  }
}

// ── Group Order Room ─────────────────────────────────────────────────────────

class GroupOrder {
  final String groupOrderId;
  final String vendorId;
  final String vendorName;
  final String status; // OPEN, LOCKED, CHECKED_OUT, CANCELLED
  final List<GroupOrderParticipant> participants;
  final List<GroupOrderItem> items;
  final double totalKobo;
  final String? inviteToken;
  final String? inviteUrl;
  final GroupDiscount? groupDiscount;

  double get total => totalKobo / 100;
  bool get isOpen => status == 'OPEN';
  bool get isLocked => status == 'LOCKED';
  bool get isExpired => status == 'EXPIRED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isTerminal => isExpired || isCancelled || status == 'CHECKED_OUT';

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  const GroupOrder({
    required this.groupOrderId,
    required this.vendorId,
    required this.vendorName,
    required this.status,
    required this.participants,
    required this.items,
    required this.totalKobo,
    this.inviteToken,
    this.inviteUrl,
    this.groupDiscount,
  });

  factory GroupOrder.fromJson(Map<String, dynamic> json) {
    final gdJson = json['group_discount'] as Map<String, dynamic>?;
    return GroupOrder(
      groupOrderId: json['group_order_id'] as String? ?? '',
      vendorId: json['vendor_id'] as String? ?? '',
      vendorName: (json['vendor'] as Map<String, dynamic>?)?['display_name'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
      participants: (json['participants'] as List<dynamic>? ?? [])
          .map((e) =>
          GroupOrderParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => GroupOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalKobo: (json['subtotal_kobo'] as num?)?.toDouble() ?? 0,
      inviteToken: json['invite_token'] as String?,
      inviteUrl: json['invite_url'] as String?,
      groupDiscount: gdJson != null ? GroupDiscount.fromJson(gdJson) : null,
    );
  }
}

// ── Create Group Order Response ───────────────────────────────────────────────

class CreateGroupOrderResponse {
  final String groupOrderId;
  final String inviteUrl;
  final String inviteToken;
  final String participantToken;

  const CreateGroupOrderResponse({
    required this.groupOrderId,
    required this.inviteUrl,
    required this.inviteToken,
    required this.participantToken,
  });

  factory CreateGroupOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateGroupOrderResponse(
      groupOrderId: json['group_order_id'] as String? ?? '',
      inviteUrl: json['invite_url'] as String? ?? '',
      inviteToken: json['invite_token'] as String? ?? '',
      participantToken: json['participant_token'] as String? ?? '',
    );
  }
}

// ── Join Group Order Response ─────────────────────────────────────────────────

class JoinGroupOrderResponse {
  final String groupOrderId;
  final String participantToken;
  final String displayName;

  const JoinGroupOrderResponse({
    required this.groupOrderId,
    required this.participantToken,
    required this.displayName,
  });

  factory JoinGroupOrderResponse.fromJson(Map<String, dynamic> json) {
    return JoinGroupOrderResponse(
      groupOrderId: json['group_order_id'] as String? ?? '',
      participantToken: json['participant_token'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
    );
  }
}

// ── Invite Preview ────────────────────────────────────────────────────────────

class GroupOrderInvitePreview {
  final String groupOrderId;
  final String vendorName;
  final int participantCount;
  final String status;

  const GroupOrderInvitePreview({
    required this.groupOrderId,
    required this.vendorName,
    required this.participantCount,
    required this.status,
  });

  factory GroupOrderInvitePreview.fromJson(Map<String, dynamic> json) {
    return GroupOrderInvitePreview(
      groupOrderId: json['group_order_id'] as String? ?? '',
      vendorName: json['vendor_name'] as String? ?? '',
      participantCount: (json['participant_count'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'OPEN',
    );
  }
}

// ── Estimate Response ─────────────────────────────────────────────────────────

class GroupOrderEstimate {
  final double subtotalKobo;
  final double deliveryFeeKobo;
  final double serviceFeeKobo;
  final double totalKobo;
  final List<Map<String, dynamic>> unavailableItems;
  final List<PricedItem> pricedItems;
  final int? etaMinutes;
  final double? distanceKm;
  final String? quoteId;
  final bool canCheckout;
  final String? serviceTier;
  final String? currency;

  double get subtotal => subtotalKobo / 100;
  double get deliveryFee => deliveryFeeKobo / 100;
  double get serviceFee => serviceFeeKobo / 100;
  double get total => totalKobo / 100;

  const GroupOrderEstimate({
    required this.subtotalKobo,
    required this.deliveryFeeKobo,
    required this.serviceFeeKobo,
    required this.totalKobo,
    required this.unavailableItems,
    required this.pricedItems,
    this.etaMinutes,
    this.distanceKm,
    this.quoteId,
    required this.canCheckout,
    this.serviceTier,
    this.currency,
  });

  factory GroupOrderEstimate.fromJson(Map<String, dynamic> json) {
    double parseKobo(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0;
      return 0;
    }

    // Parse priced items
    final pricedItemsList = (json['priced_items'] as List<dynamic>? ?? [])
        .map((item) => PricedItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return GroupOrderEstimate(
      subtotalKobo: parseKobo(json['subtotal_kobo']),
      deliveryFeeKobo: parseKobo(json['delivery_fee_kobo']),
      serviceFeeKobo: parseKobo(json['service_fee_kobo'] ?? 0),
      totalKobo: parseKobo(json['total_kobo']),
      unavailableItems: (json['unavailable_items'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      pricedItems: pricedItemsList,
      etaMinutes: json['eta_minutes'] as int?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      quoteId: json['quote_id'] as String?,
      canCheckout: json['can_checkout'] as bool? ?? false,
      serviceTier: json['service_tier'] as String?,
      currency: json['currency'] as String?,
    );
  }
}

class PricedItem {
  final String itemId;
  final String name;
  final int quantity;
  final double unitPriceKobo;
  final String? participantId;
  final String? participantDisplayName;
  final Map<String, dynamic>? metadata;

  double get unitPrice => unitPriceKobo / 100;
  double get totalPrice => (unitPriceKobo * quantity) / 100;

  PricedItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.unitPriceKobo,
    this.participantId,
    this.participantDisplayName,
    this.metadata,
  });

  factory PricedItem.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>?;

    return PricedItem(
      itemId: json['item_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown item',
      quantity: json['qty'] as int? ?? 0,
      unitPriceKobo: (json['unit_price_kobo'] as num?)?.toDouble() ?? 0,
      participantId: metadata?['participant_id'] as String?,
      participantDisplayName: metadata?['participant_display_name'] as String?,
      metadata: metadata,
    );
  }
}

// ── Checkout Response ─────────────────────────────────────────────────────────

class GroupOrderCheckoutResponse {
  final String orderId;
  final String state;
  final Map<String, dynamic>? orderData;
  final Map<String, dynamic>? groupOrderData;

  const GroupOrderCheckoutResponse({
    required this.orderId,
    required this.state,
    this.orderData,
    this.groupOrderData,
  });

  factory GroupOrderCheckoutResponse.fromJson(Map<String, dynamic> json) {
    // Backend wraps in order object
    final order = json['order'] as Map<String, dynamic>? ?? json;
    return GroupOrderCheckoutResponse(
      orderId: order['order_id'] as String? ?? '',
      state: order['state'] as String? ?? 'DRAFT',
      orderData: json['order'] as Map<String, dynamic>?,
      groupOrderData: json['group_order'] as Map<String, dynamic>?,
    );
  }
}