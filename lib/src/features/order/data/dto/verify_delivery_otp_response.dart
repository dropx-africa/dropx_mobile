/// Response data for `POST /orders/:id/delivery-otp/verify`.
///
/// This records the customer's confirmation of the delivery handoff — it
/// does not close the order. The assigned rider still completes delivery
/// separately.
class VerifyDeliveryOtpData {
  final String orderId;
  final String state;
  final DateTime? deliveredAt;
  final int attemptsRemaining;
  final DateTime? lockoutExpiresAt;

  const VerifyDeliveryOtpData({
    required this.orderId,
    required this.state,
    this.deliveredAt,
    required this.attemptsRemaining,
    this.lockoutExpiresAt,
  });

  factory VerifyDeliveryOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyDeliveryOtpData(
      orderId: json['order_id'] as String? ?? '',
      state: json['state'] as String? ?? 'UNKNOWN',
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'] as String)
          : null,
      attemptsRemaining: (json['attempts_remaining'] as num?)?.toInt() ?? 0,
      lockoutExpiresAt: json['lockout_expires_at'] != null
          ? DateTime.tryParse(json['lockout_expires_at'] as String)
          : null,
    );
  }
}
