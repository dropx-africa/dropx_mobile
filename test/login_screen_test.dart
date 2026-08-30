import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dropx_mobile/src/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Wrap in MaterialApp for context
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Verify static texts
    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Login to your account to continue.'), findsOneWidget);

    // Email is the default login tab; phone remains available as a tab.
    expect(find.text('Email'), findsWidgets);
    expect(find.text('Phone'), findsOneWidget);

    // Verify Buttons
    expect(find.text('Send OTP Code'), findsOneWidget);
    // expect(find.text('Google'), findsOneWidget); // Removed in this view
    // expect(find.text('Apple'), findsOneWidget); // Removed in this view
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
    // expect(find.text('Sign Up'), findsOneWidget); // Removed/Changed
  });
}
