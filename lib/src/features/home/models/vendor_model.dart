class Vendor {
  final String id;
  final String name;
  final String description;
  final double rating;
  final int ratingCount;
  final String deliveryTime;
  final double deliveryFee;
  final String imageUrl;
  final String logoUrl;
  final List<String> tags;
  final bool isFeatured;
  final bool isFastest;
  final String? accuracyBadge; // e.g., "98% Accurate"

  const Vendor({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.ratingCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.imageUrl,
    required this.logoUrl,
    required this.tags,
    this.isFeatured = false,
    this.isFastest = false,
    this.accuracyBadge,
  });
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String prepTime;
  final List<String> badges; // e.g., "156 ordered today", "Chef's Pick"
  final String category;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.prepTime,
    this.badges = const [],
    required this.category,
  });
}
