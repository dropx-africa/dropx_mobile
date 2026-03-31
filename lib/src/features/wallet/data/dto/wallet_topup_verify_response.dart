class WalletTopupVerifyData {
  final bool verified;
  final String paymentAttemptId;
  final String paymentStatus;
  final String providerStatus;
  final String reference;
  final String availableBalanceKobo;

  const WalletTopupVerifyData({
    required this.verified,
    required this.paymentAttemptId,
    required this.paymentStatus,
    required this.providerStatus,
    required this.reference,
    required this.availableBalanceKobo,
  });

  factory WalletTopupVerifyData.fromJson(Map<String, dynamic> json) {
    return WalletTopupVerifyData(
      verified: json['verified'] as bool,
      paymentAttemptId: json['payment_attempt_id'] as String,
      paymentStatus: json['payment_status'] as String,
      providerStatus: json['provider_status'] as String,
      reference: json['reference'] as String,
      availableBalanceKobo: json['available_balance_kobo'].toString(),
    );
  }
}
