class OrderModel {
  final String id;
  final String vendorName;
  final String vendorLogo;
  final String itemsSummary; // e.g., "2x Jollof Rice, 1x Chicken"
  final String date;
  final double price;
  final String status; // "Delivered", "Cancelled"

  const OrderModel({
    required this.id,
    required this.vendorName,
    required this.vendorLogo,
    required this.itemsSummary,
    required this.date,
    required this.price,
    required this.status,
  });
}
