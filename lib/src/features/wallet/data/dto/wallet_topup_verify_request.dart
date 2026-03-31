class WalletTopupVerifyRequest {
  final String paymentAttemptId;
  final String reference;

  const WalletTopupVerifyRequest({
    required this.paymentAttemptId,
    required this.reference,
  });

  Map<String, dynamic> toJson() => {
    'payment_attempt_id': paymentAttemptId,
    'reference': reference,
  };
}
