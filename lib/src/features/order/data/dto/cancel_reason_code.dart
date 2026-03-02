/// Standardised cancellation reason codes.
///
/// Each value maps to an API-level snake_case string via [toApiString].
enum CancelReasonCode {
  customerChangedMind,
  deliveryTooSlow,
  wrongAddress,
  duplicateOrder,
  foundBetterPrice,
  paymentIssue,
  vendorUnresponsive,
  other;

  /// Returns the API-level string representation.
  String toApiString() {
    switch (this) {
      case CancelReasonCode.customerChangedMind:
        return 'CUSTOMER_CHANGED_MIND';
      case CancelReasonCode.deliveryTooSlow:
        return 'DELIVERY_TOO_SLOW';
      case CancelReasonCode.wrongAddress:
        return 'WRONG_ADDRESS';
      case CancelReasonCode.duplicateOrder:
        return 'DUPLICATE_ORDER';
      case CancelReasonCode.foundBetterPrice:
        return 'FOUND_BETTER_PRICE';
      case CancelReasonCode.paymentIssue:
        return 'PAYMENT_ISSUE';
      case CancelReasonCode.vendorUnresponsive:
        return 'VENDOR_UNRESPONSIVE';
      case CancelReasonCode.other:
        return 'OTHER';
    }
  }

  /// Human-readable label shown in the UI dropdown.
  String get displayLabel {
    switch (this) {
      case CancelReasonCode.customerChangedMind:
        return 'Changed my mind';
      case CancelReasonCode.deliveryTooSlow:
        return 'Delivery is too slow';
      case CancelReasonCode.wrongAddress:
        return 'Wrong address entered';
      case CancelReasonCode.duplicateOrder:
        return 'Duplicate order';
      case CancelReasonCode.foundBetterPrice:
        return 'Found a better price';
      case CancelReasonCode.paymentIssue:
        return 'Payment issue';
      case CancelReasonCode.vendorUnresponsive:
        return 'Vendor not responding';
      case CancelReasonCode.other:
        return 'Other reason';
    }
  }
}
