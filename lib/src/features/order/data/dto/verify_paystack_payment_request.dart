/// Request DTO for `POST /payments/verify/paystack`.
class VerifyPaystackPaymentRequest {
  final String orderId;
  final String reference;

  const VerifyPaystackPaymentRequest({
    required this.orderId,
    required this.reference,
  });

  Map<String, dynamic> toJson() => {
    'order_id': orderId,
    'reference': reference,
  };
}
