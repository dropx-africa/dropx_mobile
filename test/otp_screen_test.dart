import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/features/auth/presentation/otp_screen.dart';

void main() {
  testWidgets('OtpScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OtpScreen(
            phoneNumber: '+2348012345678',
            otpChallengeId: 'test-challenge-id',
          ),
        ),
      ),
    );

    // Verify Title
    expect(find.text('Verify Phone'), findsOneWidget);
    expect(
      find.text('Enter the 6-digit code we sent to +2348012345678'),
      findsOneWidget,
    );

    // Verify Button
    expect(find.text('Verify & Continue'), findsOneWidget);

    // Verify Link
    expect(find.text('Change Phone Number'), findsOneWidget);
  });
}
