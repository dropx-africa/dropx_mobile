/// Standardised dispute reason codes.
///
/// Each value maps to an API-level snake_case string via [toApiString].
enum DisputeReasonCode {
  itemMissing,
  wrongItem,
  itemDamaged,
  neverDelivered,
  chargedTwice,
  other;

  /// Returns the API-level string representation.
  String toApiString() {
    switch (this) {
      case DisputeReasonCode.itemMissing:
        return 'ITEM_MISSING';
      case DisputeReasonCode.wrongItem:
        return 'WRONG_ITEM';
      case DisputeReasonCode.itemDamaged:
        return 'ITEM_DAMAGED';
      case DisputeReasonCode.neverDelivered:
        return 'NEVER_DELIVERED';
      case DisputeReasonCode.chargedTwice:
        return 'CHARGED_TWICE';
      case DisputeReasonCode.other:
        return 'OTHER';
    }
  }

  /// Human-readable label shown in the UI dropdown.
  String get displayLabel {
    switch (this) {
      case DisputeReasonCode.itemMissing:
        return 'Item was missing';
      case DisputeReasonCode.wrongItem:
        return 'Wrong item delivered';
      case DisputeReasonCode.itemDamaged:
        return 'Item was damaged';
      case DisputeReasonCode.neverDelivered:
        return 'Order never delivered';
      case DisputeReasonCode.chargedTwice:
        return 'Charged twice';
      case DisputeReasonCode.other:
        return 'Other reason';
    }
  }
}
