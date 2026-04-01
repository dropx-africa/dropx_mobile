class PlaceOrderResponse {
  final String orderId;
  final String state;

  const PlaceOrderResponse({required this.orderId, required this.state});

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json) {
    final order = (json['order'] ?? json) as Map<String, dynamic>;
    return PlaceOrderResponse(
      orderId: order['order_id'] as String? ?? '',
      state: order['state'] as String? ?? '',
    );
  }
}
