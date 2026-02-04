import 'package:flutter/material.dart';

import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:dropx_mobile/src/features/auth/presentation/login_screen.dart';
import 'package:dropx_mobile/src/features/auth/presentation/otp_screen.dart';
import 'package:dropx_mobile/src/features/location/presentation/manual_location_screen.dart';
import 'package:dropx_mobile/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:dropx_mobile/src/features/menu/presentation/vendor_menu_screen.dart';
import 'package:dropx_mobile/src/features/home/models/vendor_model.dart';
import 'package:dropx_mobile/src/features/cart/presentation/cart_screen.dart';
import 'package:dropx_mobile/src/features/order/presentation/order_tracking_screen.dart';

abstract class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoute.onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const OnboardingScreen(),
        );

      case AppRoute.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const LoginScreen(),
        );

      case AppRoute.otp:
        final args = settings.arguments as Map<String, dynamic>?;
        final phoneNumber = args?['phoneNumber'] as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => OtpScreen(phoneNumber: phoneNumber),
        );

      case AppRoute.manualLocation:
        final args = settings.arguments as Map<String, dynamic>?;
        final isGuest = args?['isGuest'] as bool? ?? false;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ManualLocationScreen(isGuest: isGuest),
        );

      case AppRoute.dashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        final isGuest = args?['isGuest'] as bool? ?? false;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => DashboardScreen(isGuest: isGuest),
        );

      case AppRoute.vendorMenu:
        final args = settings.arguments as Map<String, dynamic>;
        final vendor = args['vendor'] as Vendor;
        final isGuest = args['isGuest'] as bool? ?? false;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) =>
              VendorMenuScreen(vendor: vendor, isGuest: isGuest),
        );

      case AppRoute.cart:
        final args = settings.arguments as Map<String, dynamic>?;
        final isGuest = args?['isGuest'] as bool? ?? false;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => CartScreen(isGuest: isGuest),
        );

      case AppRoute.orderTracking:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const OrderTrackingScreen(),
        );

      // Default Route (e.g., Onboarding)
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const OnboardingScreen(),
        );
    }
  }
}
