import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_application_tracker/app/app.dart';

void main() {
  testWidgets('App renders main navigation and switches tabs', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    
    await tester.pumpWidget(const App(initialThemeMode: ThemeMode.system));

    // Wait for async loads
    await tester.pumpAndSettle();

    // Verify Dashboard is initially visible
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Applications'), findsWidgets);
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Initial Dashboard content check
    expect(find.text('Job Application Tracker'), findsOneWidget);
    expect(find.text('Here is a summary of your job search journey.'), findsOneWidget);

    // Tap Applications tab
    await tester.tap(find.text('Applications').last);
    await tester.pumpAndSettle();
    expect(find.text('Keep track of every opportunity in one place.'), findsOneWidget);

    // Tap Statistics tab
    await tester.tap(find.text('Statistics'));
    await tester.pumpAndSettle();
    expect(find.text('No statistics yet'), findsOneWidget);

    // Return to Dashboard tab
    await tester.tap(find.text('Dashboard').last);
    await tester.pumpAndSettle();
    expect(find.text('Here is a summary of your job search journey.'), findsOneWidget);
  });
}

