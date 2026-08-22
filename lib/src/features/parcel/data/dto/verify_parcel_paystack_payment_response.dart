/// Response data for `POST /parcels/:id/payments/verify/paystack`.
class VerifyParcelPaystackPaymentData {
  final bool verified;
  final String reference;
  final String providerStatus;
  final String paymentStatus;
  final String parcelState;
  final String? paymentAttemptId;
  final String? placementStatus;
  final String? placementBlockCode;
  final String? reconciliationStatus;
  final String? reconciliationReason;

  const VerifyParcelPaystackPaymentData({
    required this.verified,
    required this.reference,
    required this.providerStatus,
    required this.paymentStatus,
    required this.parcelState,
    this.paymentAttemptId,
    this.placementStatus,
    this.placementBlockCode,
    this.reconciliationStatus,
    this.reconciliationReason,
  });

  factory VerifyParcelPaystackPaymentData.fromJson(Map<String, dynamic> json) {
    return VerifyParcelPaystackPaymentData(
      verified: json['verified'] as bool? ?? false,
      reference: json['reference'] as String? ?? '',
      providerStatus: json['provider_status'] as String? ?? '',
      paymentStatus: json['payment_status'] as String? ?? '',
      parcelState: json['parcel_state'] as String? ?? '',
      paymentAttemptId: json['payment_attempt_id'] as String?,
      placementStatus: json['placement_status'] as String?,
      placementBlockCode: json['placement_block_code'] as String?,
      reconciliationStatus: json['reconciliation_status'] as String?,
      reconciliationReason: json['reconciliation_reason'] as String?,
    );
  }
}
