class WalletTopupInitializeData {
  final String paymentAttemptId;
  final String authorizationUrl;
  final String reference;
  final String status;
  final String amountKobo;

  const WalletTopupInitializeData({
    required this.paymentAttemptId,
    required this.authorizationUrl,
    required this.reference,
    required this.status,
    required this.amountKobo,
  });

  factory WalletTopupInitializeData.fromJson(Map<String, dynamic> json) {
    return WalletTopupInitializeData(
      paymentAttemptId: json['payment_attempt_id'] as String,
      authorizationUrl: json['authorization_url'] as String,
      reference: json['reference'] as String,
      status: json['status'] as String,
      amountKobo: json['amount_kobo'].toString(),
    );
  }
}
