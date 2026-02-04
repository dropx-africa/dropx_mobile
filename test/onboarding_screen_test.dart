import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dropx_mobile/src/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    // Verify initial page content
    expect(find.text('Fast & Reliable Delivery'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Get Started'), findsNothing);

    // Verify navigation buttons
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Real-Time Tracking'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Secure Payments'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
