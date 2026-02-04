import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dropx_mobile/src/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Wrap in MaterialApp for context
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Verify static texts
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Enter your phone number to login or sign up.'), findsOneWidget);
    
    // Verify Inputs
    expect(find.byIcon(Icons.phone_android), findsOneWidget); 
    
    // Verify Buttons
    expect(find.text('Continue'), findsOneWidget);
    // expect(find.text('Google'), findsOneWidget); // Removed in this view
    // expect(find.text('Apple'), findsOneWidget); // Removed in this view
    expect(find.text('Continue as Guest'), findsOneWidget);
    // expect(find.text('Sign Up'), findsOneWidget); // Removed/Changed
  });
}
