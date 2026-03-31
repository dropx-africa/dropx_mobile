import 'package:flutter/material.dart';

import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:dropx_mobile/src/features/auth/presentation/login_screen.dart';
import 'package:dropx_mobile/src/features/auth/presentation/sign_up_screen.dart';
import 'package:dropx_mobile/src/features/auth/presentation/otp_screen.dart';
import 'package:dropx_mobile/src/features/auth/presentation/forgot_password_screen.dart';
import 'package:dropx_mobile/src/features/auth/presentation/reset_password_screen.dart';
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
import 'package:dropx_mobile/src/features/home/presentation/featured_food_screen.dart';
import 'package:dropx_mobile/src/features/home/presentation/fastest_food_screen.dart';
import 'package:dropx_mobile/src/features/profile/presentation/notifications_screen.dart';
import 'package:dropx_mobile/src/features/wallet/presentation/wallet_topup_screen.dart';
import 'package:dropx_mobile/src/features/wallet/presentation/wallet_topup_checkout_screen.dart';
import 'package:dropx_mobile/src/features/profile/presentation/edit_profile_screen.dart';
import 'package:dropx_mobile/src/features/profile/presentation/contact_sync_screen.dart';
import 'package:dropx_mobile/src/features/profile/presentation/social_feed_screen.dart';
import 'package:dropx_mobile/src/features/profile/presentation/preferences_screen.dart';
import 'package:dropx_mobile/src/features/profile/presentation/notification_settings_screen.dart';
import 'package:dropx_mobile/src/features/profile/presentation/support_tickets_screen.dart';

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
        final sentTo = args?['sentTo'] as String? ?? '';
        final channel = args?['channel'] as String? ?? 'sms';
        final otpChallengeId = args?['otpChallengeId'] as String? ?? '';
        final resendAvailableAt = args?['resendAvailableAt'] as String?;
        final purpose = args?['purpose'] as String? ?? 'LOGIN';
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => OtpScreen(
            sentTo: sentTo,
            channel: channel,
            otpChallengeId: otpChallengeId,
            resendAvailableAt: resendAvailableAt,
            purpose: purpose,
          ),
        );

      case AppRoute.forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ForgotPasswordScreen(),
        );

      case AppRoute.resetPassword:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final resetToken = args['resetToken'] as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ResetPasswordScreen(resetToken: resetToken),
        );

      case AppRoute.manualLocation:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ManualLocationScreen(),
        );

      case AppRoute.dashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        final initialTab = args?['initialTab'] as int? ?? 0;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => DashboardScreen(initialTab: initialTab),
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
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final orderId = args['orderId'] as String?;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => OrderTrackingScreen(orderId: orderId),
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

      case AppRoute.featuredFood:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const FeaturedFoodScreen(),
        );

      case AppRoute.fastestFood:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const FastestFoodScreen(),
        );

      case AppRoute.notifications:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const NotificationsScreen(),
        );

      case AppRoute.walletTopup:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const WalletTopupScreen(),
        );

      case AppRoute.walletTopupCheckout:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final authorizationUrl = args['authorizationUrl'] as String;
        final reference = args['reference'] as String;
        final paymentAttemptId = args['paymentAttemptId'] as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => WalletTopupCheckoutScreen(
            authorizationUrl: authorizationUrl,
            reference: reference,
            paymentAttemptId: paymentAttemptId,
          ),
        );

      case AppRoute.editProfile:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const EditProfileScreen(),
        );

      case AppRoute.contactSync:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ContactSyncScreen(),
        );

      case AppRoute.socialFeed:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const SocialFeedScreen(),
        );

      case AppRoute.preferences:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const PreferencesScreen(),
        );

      case AppRoute.notificationSettings:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const NotificationSettingsScreen(),
        );

      case AppRoute.supportTickets:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const SupportTicketsScreen(),
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
