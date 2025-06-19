import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaibee1/main.dart';
import 'package:jaibee1/features/home/jaibee_home_screen.dart';
import 'package:jaibee1/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('App shows onboarding if not completed', (WidgetTester tester) async {
    await tester.pumpWidget(
      const JaibeeTrackerApp(initialRoute: 'onboarding'),
    );

    // Expect to find onboarding text
    expect(find.text('Track Your Spending'), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('App shows home if onboarding completed', (WidgetTester tester) async {
    await tester.pumpWidget(
      const JaibeeTrackerApp(initialRoute: 'home'),
    );

    // Assuming your Home screen has this title
    expect(find.byType(JaibeeHomeScreen), findsOneWidget);
  });
}
