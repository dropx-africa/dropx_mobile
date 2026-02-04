import 'package:dropx_mobile/src/features/home/models/vendor_model.dart';

// Helper to access assets
const _baseImagePath = "assets/images";

final List<Vendor> mockVendors = [
  Vendor(
    id: 'v1',
    name: "Mama Put's Kitchen",
    description: "Authentic Nigerian Cuisine",
    rating: 4.8,
    ratingCount: 500,
    deliveryTime: "25-35 min",
    deliveryFee: 400,
    imageUrl: "$_baseImagePath/vendor_banner.png",
    logoUrl:
        "$_baseImagePath/vendor_banner.png", // Using banner as logo for now
    tags: ["Local", "Rice", "Swallow"],
    isFeatured: true,
    accuracyBadge: "98% Accurate",
  ),
  Vendor(
    id: 'v2',
    name: "Kofi's Grill",
    description: "Best Grilled Chicken in Town",
    rating: 4.5,
    ratingCount: 320,
    deliveryTime: "15-25 min",
    deliveryFee: 300,
    imageUrl: "$_baseImagePath/food_jollof.png",
    logoUrl: "$_baseImagePath/food_jollof.png",
    tags: ["Grill", "Chicken", "Spicy"],
    isFastest: true,
  ),
  Vendor(
    id: 'v3',
    name: "Iya Basira",
    description: "Home of Amala",
    rating: 4.7,
    ratingCount: 450,
    deliveryTime: "30-45 min",
    deliveryFee: 500,
    imageUrl: "$_baseImagePath/vendor_banner.png", // Reuse
    logoUrl: "$_baseImagePath/vendor_banner.png",
    tags: ["Local", "Amala", "Soup"],
    isFeatured: true,
  ),
];

final List<MenuItem> mockMenuItems = [
  MenuItem(
    id: 'm1',
    name: "Jollof Rice & Chicken",
    description: "Smoky party jollof with fried chicken and plantain",
    price: 2500,
    imageUrl: "$_baseImagePath/food_jollof.png",
    prepTime: "20 min prep time",
    badges: ["156 ordered today", "Chef's Pick"],
    category: "Most Popular",
  ),
  MenuItem(
    id: 'm2',
    name: "Egusi & Pounded Yam",
    description: "Rich egusi soup with assorted meat and smooth pounded yam",
    price: 3000,
    imageUrl:
        "$_baseImagePath/food_jollof.png", // Reuse jollof for now since egusi failed
    prepTime: "25 min prep time",
    badges: ["Best Seller"],
    category: "Swallow",
  ),
  MenuItem(
    id: 'm3',
    name: "Fried Rice & Turkey",
    description: "Classic fried rice served with succulent turkey wings",
    price: 3500,
    imageUrl: "$_baseImagePath/food_jollof.png",
    prepTime: "20 min prep time",
    badges: [],
    category: "Most Popular",
  ),
];
