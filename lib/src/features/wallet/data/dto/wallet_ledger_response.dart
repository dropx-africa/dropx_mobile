class WalletLedgerEntry {
  final String ledgerEntryId;
  final String direction; // CREDIT | DEBIT
  final String amountKobo;
  final String reasonCode;
  final String? relatedType;
  final String? relatedId;
  final String createdAt;

  const WalletLedgerEntry({
    required this.ledgerEntryId,
    required this.direction,
    required this.amountKobo,
    required this.reasonCode,
    this.relatedType,
    this.relatedId,
    required this.createdAt,
  });

  factory WalletLedgerEntry.fromJson(Map<String, dynamic> json) {
    return WalletLedgerEntry(
      ledgerEntryId: json['ledger_entry_id'] as String,
      direction: json['direction'] as String,
      amountKobo: json['amount_kobo'].toString(),
      reasonCode: json['reason_code'] as String,
      relatedType: json['related_type'] as String?,
      relatedId: json['related_id'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}

class WalletLedgerData {
  final List<WalletLedgerEntry> entries;
  final String? nextCursor;

  const WalletLedgerData({required this.entries, this.nextCursor});

  factory WalletLedgerData.fromJson(Map<String, dynamic> json) {
    return WalletLedgerData(
      entries: (json['entries'] as List<dynamic>)
          .map((e) => WalletLedgerEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }
}
