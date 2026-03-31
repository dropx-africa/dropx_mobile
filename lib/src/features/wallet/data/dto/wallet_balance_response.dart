class WalletBalance {
  final String currency;
  final String availableBalanceKobo;
  final String pendingBalanceKobo;
  final String? lastUpdatedAt;

  const WalletBalance({
    required this.currency,
    required this.availableBalanceKobo,
    required this.pendingBalanceKobo,
    this.lastUpdatedAt,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      currency: json['currency'] as String,
      availableBalanceKobo: json['available_balance_kobo'].toString(),
      pendingBalanceKobo: json['pending_balance_kobo'].toString(),
      lastUpdatedAt: json['last_updated_at'] as String?,
    );
  }
}
