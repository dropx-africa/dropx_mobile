import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropx_mobile/src/utils/app_theme.dart';
import 'package:dropx_mobile/src/route/route.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/core/services/session_service.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();
  final sessionService = SessionService(prefs);

  // Restore auth token from saved session so API calls are authenticated.
  final savedToken = sessionService.authToken;
  final savedRefreshToken = sessionService.refreshToken;
  if (kDebugMode) {
    print(
      '[Main] Restoring session — isLoggedIn: ${sessionService.isLoggedIn}, '
      'token: ${savedToken != null && savedToken.isNotEmpty ? '${savedToken.substring(0, 10)}...' : 'EMPTY/NULL'}',
    );
  }
  if (savedToken != null && savedToken.isNotEmpty) {
    ApiClient().setAuthToken(savedToken, refreshToken: savedRefreshToken);
    ApiClient().onTokenRefreshed = (token, refresh) {
      sessionService.saveAuthSession(
        accessToken: token,
        refreshToken: refresh,
        userId: sessionService.userId ?? '',
        fullName: sessionService.fullName,
        phone: sessionService.phone,
      );
    };
    ApiClient().onUnauthorized = () async {
      await sessionService.clearSession();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoute.login,
        (route) => false,
      );
    };
    if (kDebugMode) print('[Main] ✅ Auth token restored to ApiClient');
  } else {
    if (kDebugMode) print('[Main] ⚠️ No auth token to restore');
  }

  runApp(
    ProviderScope(
      overrides: [sessionServiceProvider.overrideWithValue(sessionService)],
      child: MyApp(initialRoute: sessionService.getInitialRoute()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'DropX',
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
