/// Request DTO for `POST /parcels/:id/payments/verify/paystack`.
class VerifyParcelPaystackPaymentRequest {
  final String parcelId;
  final String reference;

  const VerifyParcelPaystackPaymentRequest({
    required this.parcelId,
    required this.reference,
  });

  Map<String, dynamic> toJson() => {
    'parcel_id': parcelId,
    'reference': reference,
  };
}
