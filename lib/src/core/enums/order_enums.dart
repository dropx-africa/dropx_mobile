/// Order types supported by the GenericOrderScreen.
enum OrderType {
  parcel('Parcel'),
  pharmacy('Pharmacy'),
  retail('Retail');

  final String label;
  const OrderType(this.label);

  static OrderType fromString(String value) {
    return OrderType.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => OrderType.parcel,
    );
  }
}

/// Status of an order throughout its lifecycle.
enum OrderStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  preparing('Preparing'),
  pickedUp('Picked Up'),
  onTheWay('On the Way'),
  delivered('Delivered'),
  cancelled('Cancelled');

  final String label;
  const OrderStatus(this.label);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }
}
