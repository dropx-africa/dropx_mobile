import 'package:flutter/material.dart';

import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:dropx_mobile/src/features/auth/presentation/login_screen.dart';
import 'package:dropx_mobile/src/features/auth/presentation/sign_up_screen.dart';
import 'package:dropx_mobile/src/features/auth/presentation/otp_screen.dart';
import 'package:dropx_mobile/src/features/location/presentation/manual_location_screen.dart';
import 'package:dropx_mobile/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:dropx_mobile/src/features/menu/presentation/vendor_menu_screen.dart';

import 'package:dropx_mobile/src/features/cart/presentation/cart_screen.dart';
import 'package:dropx_mobile/src/features/order/presentation/order_tracking_screen.dart';
import 'package:dropx_mobile/src/features/order/presentation/receipt_screen.dart';
import 'package:dropx_mobile/src/features/order/presentation/transaction_details_screen.dart';
import 'package:dropx_mobile/src/features/order/presentation/order_success_screen.dart';
import 'package:dropx_mobile/src/features/order/presentation/paystack_checkout_screen.dart';
import 'package:dropx_mobile/src/features/parcel/presentation/generic_order_screen.dart';
import 'package:dropx_mobile/src/features/group/presentation/poll_result_screen.dart';
import 'package:dropx_mobile/src/features/paylink/presentation/pay_link_screen.dart';

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

      case AppRoute.signUp:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const SignUpScreen(),
        );

      case AppRoute.otp:
        final args = settings.arguments as Map<String, dynamic>?;
        final phoneNumber = args?['phoneNumber'] as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => OtpScreen(phoneNumber: phoneNumber),
        );

      case AppRoute.manualLocation:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ManualLocationScreen(),
        );

      case AppRoute.dashboard:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => DashboardScreen(),
        );

      case AppRoute.vendorMenu:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final vendorId = args['vendorId'] as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => VendorMenuScreen(vendorId: vendorId),
        );

      case AppRoute.cart:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => CartScreen(),
        );

      case AppRoute.orderTracking:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const OrderTrackingScreen(),
        );

      case AppRoute.receipt:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        // Pass empty map if null, screen handles defaults
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ReceiptScreen(orderDetails: args),
        );

      case AppRoute.transactionDetails:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => TransactionDetailsScreen(orderDetails: args),
        );

      case AppRoute.genericOrder:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final orderType = args['orderType'] as OrderType? ?? OrderType.parcel;
        final preFilledItem = args['preFilledItem'] as String?;
        final quantity = args['quantity'] as int?;
        final isGroupOrder = args['isGroupOrder'] as bool? ?? false;

        return MaterialPageRoute(
          settings: settings,
          builder: (context) => GenericOrderScreen(
            orderType: orderType,
            preFilledItem: preFilledItem,
            quantity: quantity,
            isGroupOrder: isGroupOrder,
          ),
        );

      case AppRoute.pollResult:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const PollResultScreen(),
        );

      case AppRoute.paystackCheckout:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final authorizationUrl = args['authorizationUrl'] as String;
        final reference = args['reference'] as String;
        final orderId = args['orderId'] as String;

        return MaterialPageRoute(
          settings: settings,
          builder: (context) => PaystackCheckoutScreen(
            authorizationUrl: authorizationUrl,
            reference: reference,
            orderId: orderId,
          ),
        );

      case AppRoute.orderSuccess:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final orderId = args['orderId'] as String?;
        final reference = args['reference'] as String?;

        return MaterialPageRoute(
          settings: settings,
          builder: (context) =>
              OrderSuccessScreen(orderId: orderId, reference: reference),
        );

      case AppRoute.payLink:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final token = args['token'] as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => PayLinkScreen(token: token),
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
