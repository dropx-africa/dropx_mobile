/// Response data for `POST /parcels/:id/recipient-confirmation/verify`.
class VerifyParcelRecipientConfirmationData {
  final String parcelId;
  final bool recipientConfirmationRequired;
  final String? recipientConfirmationStatus;
  final DateTime? recipientConfirmationVerifiedAt;

  const VerifyParcelRecipientConfirmationData({
    required this.parcelId,
    required this.recipientConfirmationRequired,
    this.recipientConfirmationStatus,
    this.recipientConfirmationVerifiedAt,
  });

  factory VerifyParcelRecipientConfirmationData.fromJson(
    Map<String, dynamic> json,
  ) {
    return VerifyParcelRecipientConfirmationData(
      parcelId: json['parcel_id'] as String? ?? '',
      recipientConfirmationRequired:
          json['recipient_confirmation_required'] as bool? ?? false,
      recipientConfirmationStatus:
          json['recipient_confirmation_status'] as String?,
      recipientConfirmationVerifiedAt:
          json['recipient_confirmation_verified_at'] != null
          ? DateTime.tryParse(
              json['recipient_confirmation_verified_at'] as String,
            )
          : null,
    );
  }
}
