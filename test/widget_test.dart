import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dropx_mobile/main.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/core/services/session_service.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();
    final session = SessionService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionServiceProvider.overrideWithValue(session)],
        child: const MyApp(initialRoute: '/onboarding'),
      ),
    );

    expect(find.text('Order in Seconds'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}
