class WalletTopupInitializeRequest {
  final int amountKobo;
  final String provider;
  final String payerEmail;

  const WalletTopupInitializeRequest({
    required this.amountKobo,
    required this.payerEmail,
    this.provider = 'paystack',
  });

  Map<String, dynamic> toJson() => {
    'amount_kobo': amountKobo,
    'provider': provider,
    'payer_email': payerEmail,
  };
}
