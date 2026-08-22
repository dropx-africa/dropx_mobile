/// Payment details returned by `POST /orders/:id/place` when the order was
/// placed with PAYSTACK. The backend initializes the Paystack checkout as
/// part of placing the order — there is no separate initialize call for
/// orders (unlike parcels, which are a genuine two-step flow).
class PlaceOrderPayment {
  final String mode;
  final String provider;
  final String? authorizationUrl;
  final String? reference;
  final String? paymentAttemptId;
  final String? accessCode;

  const PlaceOrderPayment({
    required this.mode,
    required this.provider,
    this.authorizationUrl,
    this.reference,
    this.paymentAttemptId,
    this.accessCode,
  });

  factory PlaceOrderPayment.fromJson(Map<String, dynamic> json) {
    return PlaceOrderPayment(
      mode: json['mode'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      authorizationUrl: json['authorization_url'] as String?,
      reference: json['provider_reference'] as String? ?? json['reference'] as String?,
      paymentAttemptId: json['payment_attempt_id'] as String?,
      accessCode: json['access_code'] as String?,
    );
  }
}

class PlaceOrderResponse {
  final String orderId;
  final String state;
  final PlaceOrderPayment? payment;

  const PlaceOrderResponse({
    required this.orderId,
    required this.state,
    this.payment,
  });

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json) {
    final order = (json['order'] ?? json) as Map<String, dynamic>;
    final paymentJson = json['payment'] as Map<String, dynamic>?;
    return PlaceOrderResponse(
      orderId: order['order_id'] as String? ?? '',
      state: order['state'] as String? ?? '',
      payment: paymentJson != null
          ? PlaceOrderPayment.fromJson(paymentJson)
          : null,
    );
  }
}
