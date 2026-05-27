import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:dropx_mobile/src/utils/app_theme.dart';
import 'package:dropx_mobile/src/route/route.dart';
import 'package:dropx_mobile/src/core/services/session_service.dart';
import 'package:dropx_mobile/src/core/services/app_firebase_service.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/utils/app_log.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLog.d('[main] WidgetsFlutterBinding initialized');

  try {
    AppLog.d('[main] Starting Firebase.initializeApp...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLog.d('[main] Firebase.initializeApp succeeded');
  } catch (e, st) {
    AppLog.e('[main] Firebase.initializeApp FAILED: $e', st.toString());
  }

  try {
    AppLog.d('[main] Starting IAppFirebaseService.initNotification...');
    await IAppFirebaseService.instance.initNotification();
    AppLog.d('[main] IAppFirebaseService.initNotification succeeded');
  } catch (e, st) {
    AppLog.e('[main] IAppFirebaseService.initNotification FAILED: $e', st.toString());
  }

  final prefs = await SharedPreferences.getInstance();
  final sessionService = SessionService(prefs);

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
      navigatorKey: appNavigatorKey,
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
