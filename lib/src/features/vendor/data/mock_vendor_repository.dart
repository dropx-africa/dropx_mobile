import 'package:dropx_mobile/src/features/vendor/data/vendor_repository.dart';
import 'package:dropx_mobile/src/models/vendor.dart';
import 'package:dropx_mobile/src/models/menu_item.dart';

/// Mock implementation of [VendorRepository] for development.
///
/// Uses hardcoded data to simulate API responses.
/// When the real API is ready, swap this for [VendorRepositoryImpl]
/// by changing a single line in [vendorRepositoryProvider].
class MockVendorRepository implements VendorRepository {
  // ── Mock Vendor Data ──────────────────────────────────────────
  static const _baseImagePath = 'assets/images';

  static final List<Vendor> _mockVendors = [
    const Vendor(
      id: 'v1',
      name: "Mama Put's Kitchen",
      description: 'Authentic Nigerian Cuisine',
      rating: 4.8,
      ratingCount: 500,
      deliveryTime: '25-35 min',
      deliveryFee: 400,
      imageUrl: '$_baseImagePath/vendor_banner.png',
      logoUrl: '$_baseImagePath/vendor_banner.png',
      tags: ['Local', 'Rice', 'Swallow'],
      category: 'Food',
      isFeatured: true,
      accuracyBadge: '98% Accurate',
    ),
    const Vendor(
      id: 'v2',
      name: "Kofi's Grill",
      description: 'Best Grilled Chicken in Town',
      rating: 4.5,
      ratingCount: 320,
      deliveryTime: '15-25 min',
      deliveryFee: 300,
      imageUrl: '$_baseImagePath/food_jollof.png',
      logoUrl: '$_baseImagePath/food_jollof.png',
      tags: ['Grill', 'Chicken', 'Spicy'],
      category: 'Food',
      isFastest: true,
    ),
    const Vendor(
      id: 'v3',
      name: 'Iya Basira',
      description: 'Home of Amala',
      rating: 4.7,
      ratingCount: 450,
      deliveryTime: '30-45 min',
      deliveryFee: 500,
      imageUrl: '$_baseImagePath/vendor_banner.png',
      logoUrl: '$_baseImagePath/vendor_banner.png',
      tags: ['Local', 'Amala', 'Soup'],
      category: 'Food',
      isFeatured: true,
    ),
    const Vendor(
      id: 'p1',
      name: 'Red Star Express',
      description: 'Reliable Nationwide Delivery',
      rating: 4.9,
      ratingCount: 1200,
      deliveryTime: '1-3 Days',
      deliveryFee: 1500,
      imageUrl: '$_baseImagePath/vendor_banner.png',
      logoUrl: '$_baseImagePath/vendor_banner.png',
      tags: ['Logistics', 'Parcel', 'Express'],
      category: 'Parcel',
      isFeatured: true,
    ),
    const Vendor(
      id: 'p2',
      name: 'GIG Logistics',
      description: 'Fast & Secure Logistics',
      rating: 4.6,
      ratingCount: 900,
      deliveryTime: 'Same Day',
      deliveryFee: 2000,
      imageUrl: '$_baseImagePath/vendor_banner.png',
      logoUrl: '$_baseImagePath/vendor_banner.png',
      tags: ['Logistics', 'Same Day'],
      category: 'Parcel',
      isFastest: true,
    ),
    const Vendor(
      id: 'ph1',
      name: 'MedPlus Pharmacy',
      description: 'Your Trusted Health Partner',
      rating: 4.8,
      ratingCount: 300,
      deliveryTime: '30-45 min',
      deliveryFee: 500,
      imageUrl: '$_baseImagePath/vendor_banner.png',
      logoUrl: '$_baseImagePath/vendor_banner.png',
      tags: ['Health', 'Meds', 'Supplements'],
      category: 'Pharmacy',
      isFeatured: true,
    ),
    const Vendor(
      id: 'r1',
      name: 'Shoprite',
      description: 'Groceries & More',
      rating: 4.5,
      ratingCount: 2000,
      deliveryTime: '45-60 min',
      deliveryFee: 800,
      imageUrl: '$_baseImagePath/vendor_banner.png',
      logoUrl: '$_baseImagePath/vendor_banner.png',
      tags: ['Groceries', 'Supermarket'],
      category: 'Retail',
      isFeatured: true,
    ),
  ];

  // ── Mock Menu Items ──────────────────────────────────────────
  static final List<MenuItem> _mockMenuItems = [
    const MenuItem(
      id: 'm1',
      name: 'Jollof Rice & Chicken',
      description: 'Smoky party jollof with fried chicken and plantain',
      price: 2500,
      imageUrl: '$_baseImagePath/food_jollof.png',
      prepTime: '20 min prep time',
      badges: ['156 ordered today', "Chef's Pick"],
      category: 'Most Popular',
      vendorId: 'v1',
    ),
    const MenuItem(
      id: 'm2',
      name: 'Jollof Rice & Chicken',
      description: 'Smoky party jollof with fried chicken',
      price: 3000,
      imageUrl: '$_baseImagePath/food_jollof.png',
      prepTime: '25 min prep time',
      badges: ['Best Seller'],
      category: 'Most Popular',
      vendorId: 'v2',
    ),
    const MenuItem(
      id: 'm3',
      name: 'Amala & Ewedu',
      description: 'Hot Amala with Gbegiri and Ewedu',
      price: 3500,
      imageUrl: '$_baseImagePath/vendor_banner.png',
      prepTime: '20 min prep time',
      badges: [],
      category: 'Swallow',
      vendorId: 'v3',
    ),
    const MenuItem(
      id: 'pi1',
      name: 'Same Day Delivery (Lagos)',
      description: 'Fast delivery within Lagos metropolis',
      price: 1500,
      imageUrl: '$_baseImagePath/vendor_banner.png',
      prepTime: 'Same Day',
      badges: ['Fast'],
      category: 'Local',
      vendorId: 'p1',
    ),
    const MenuItem(
      id: 'pi2',
      name: 'Interstate Delivery',
      description: 'Reliable delivery to other states',
      price: 3500,
      imageUrl: '$_baseImagePath/vendor_banner.png',
      prepTime: '1-3 Days',
      badges: [],
      category: 'Interstate',
      vendorId: 'p1',
    ),
    const MenuItem(
      id: 'phi1',
      name: 'Paracetamol 500mg',
      description: 'Pain relief tablets (Pack of 12)',
      price: 500,
      imageUrl: '$_baseImagePath/vendor_banner.png',
      prepTime: 'Instant',
      badges: [],
      category: 'Pain Relief',
      vendorId: 'ph1',
    ),
    const MenuItem(
      id: 'phi2',
      name: 'Vitamin C 1000mg',
      description: 'Immune system support',
      price: 1200,
      imageUrl: '$_baseImagePath/vendor_banner.png',
      prepTime: 'Instant',
      badges: ['Essential'],
      category: 'Vitamins',
      vendorId: 'ph1',
    ),
    const MenuItem(
      id: 'ri1',
      name: 'Sliced Bread',
      description: 'Freshly baked family loaf',
      price: 1200,
      imageUrl: '$_baseImagePath/vendor_banner.png',
      prepTime: 'Instant',
      badges: [],
      category: 'Bakery',
      vendorId: 'r1',
    ),
    const MenuItem(
      id: 'ri2',
      name: 'Full Cream Milk',
      description: 'Rich and creamy milk (1L)',
      price: 2500,
      imageUrl: '$_baseImagePath/vendor_banner.png',
      prepTime: 'Instant',
      badges: [],
      category: 'Dairy',
      vendorId: 'r1',
    ),
  ];

  // ── Repository Methods ──────────────────────────────────────

  @override
  Future<List<Vendor>> getVendors({String? category}) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 300));

    if (category != null) {
      return _mockVendors.where((v) => v.category == category).toList();
    }
    return _mockVendors;
  }

  @override
  Future<Vendor> getVendorById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockVendors.firstWhere(
      (v) => v.id == id,
      orElse: () => _mockVendors.first,
    );
  }

  @override
  Future<List<MenuItem>> getMenuItems(String vendorId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockMenuItems.where((m) => m.vendorId == vendorId).toList();
  }

  @override
  Future<List<Vendor>> searchVendors(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final lowered = query.toLowerCase();
    return _mockVendors
        .where(
          (v) =>
              v.name.toLowerCase().contains(lowered) ||
              v.tags.any((t) => t.toLowerCase().contains(lowered)),
        )
        .toList();
  }
}
