import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:dropx_mobile/src/utils/app_theme.dart';
import 'package:dropx_mobile/src/route/route.dart';
import 'package:dropx_mobile/src/core/services/session_service.dart';
import 'package:dropx_mobile/src/core/services/session_timeout_coordinator.dart';
import 'package:dropx_mobile/src/core/services/deep_link_service.dart';
import 'package:dropx_mobile/src/core/services/route_resume_observer.dart';
import 'dart:convert';
import 'package:dropx_mobile/src/core/services/app_firebase_service.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_log.dart';
import 'package:dropx_mobile/src/core/services/session_reset.dart';


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
  final sessionService = await SessionService.create(prefs);

  runApp(
    ProviderScope(
      overrides: [sessionServiceProvider.overrideWithValue(sessionService)],
      child: MyApp(initialRoute: sessionService.getInitialRoute()),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  SessionTimeoutCoordinator? _timeoutCoordinator;
  final DeepLinkService _deepLinkService = DeepLinkService(
    navigatorKey: appNavigatorKey,
  );
  late final RouteResumeObserver _routeResumeObserver;

  @override
  void initState() {
    super.initState();
    _routeResumeObserver = RouteResumeObserver(ref.read(sessionServiceProvider));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimeoutCoordinator();
      _deepLinkService.start();
      _resumeLastRoute();
    });
  }

  /// Resumes whichever allowlisted screen the customer was last viewing
  /// when the app was closed, instead of always landing back on the
  /// dashboard after a cold restart.
  void _resumeLastRoute() {
    // Only when the app is landing on the normal dashboard flow — not
    // onboarding/login/location, where there's nothing to resume into.
    if (widget.initialRoute != AppRoute.dashboard) return;

    final session = ref.read(sessionServiceProvider);
    final name = session.lastRouteName;
    final argsJson = session.lastRouteArgsJson;
    // Already on the dashboard via initialRoute — nothing to push on top.
    if (name == null || name == AppRoute.dashboard) return;

    Map<String, dynamic>? args;
    if (argsJson != null) {
      try {
        final decoded = jsonDecode(argsJson);
        if (decoded is Map<String, dynamic>) args = decoded;
      } catch (_) {
        return;
      }
    }

    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushNamed(name, arguments: args);
  }

  void _startTimeoutCoordinator() {
    final coordinator = SessionTimeoutCoordinator(
      apiClient: ref.read(apiClientProvider),
      session: ref.read(sessionServiceProvider),
      onTimeout: () async {
        await ref.read(sessionServiceProvider).clearSession();
        clearUserScopedProviders(ref);
        appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoute.login,
          (route) => false,
        );
      },
    );
    _timeoutCoordinator = coordinator;
    coordinator.start();
  }

  @override
  void dispose() {
    _timeoutCoordinator?.dispose();
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DropX',
      theme: AppTheme.lightTheme,
      navigatorKey: appNavigatorKey,
      navigatorObservers: [_routeResumeObserver],
      initialRoute: widget.initialRoute,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (context, child) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _timeoutCoordinator?.recordActivity(),
          child: child,
        );
      },
    );
  }
}
