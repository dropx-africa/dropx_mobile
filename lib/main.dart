import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/utils/app_theme.dart';
import 'package:dropx_mobile/src/route/route.dart';
import 'package:dropx_mobile/src/route/page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'DropX',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoute.onboarding,
     debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
