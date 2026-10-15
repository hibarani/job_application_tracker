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
    expect(
      find.text('Here is a summary of your job search journey.'),
      findsOneWidget,
    );

    // Tap Applications tab
    await tester.tap(find.text('Applications').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Keep track of every opportunity in one place.'),
      findsOneWidget,
    );

    // Tap Statistics tab
    await tester.tap(find.text('Statistics'));
    await tester.pumpAndSettle();
    expect(find.text('No statistics yet'), findsOneWidget);

    // Return to Dashboard tab
    await tester.tap(find.text('Dashboard').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Here is a summary of your job search journey.'),
      findsOneWidget,
    );
  });

  testWidgets('Dashboard recent application tile opens details screen on tap', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    SharedPreferences.setMockInitialValues({
      'job_applications':
          '[{'
          '"id":"dash_app_1",'
          '"companyName":"Google",'
          '"jobTitle":"Flutter Specialist",'
          '"location":"Remote",'
          '"applicationDate":"${now.toIso8601String()}",'
          '"status":"interview",'
          '"jobUrl":"https://google.com/jobs",'
          '"salary":160000.0,'
          '"notes":"Interviewing next week",'
          '"contactName":"Alex",'
          '"isFavorite":true'
          '}]',
    });

    await tester.pumpWidget(const App(initialThemeMode: ThemeMode.dark));
    await tester.pumpAndSettle();

    // Verify application is listed on Dashboard
    expect(find.text('Flutter Specialist'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);

    // Scroll tile into view and tap the recent application tile on Dashboard
    await tester.ensureVisible(find.text('Flutter Specialist'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flutter Specialist'));
    await tester.pumpAndSettle();

    // Verify Application Details screen is open
    expect(find.text('Application Details'), findsOneWidget);
    expect(find.text('Location'), findsNothing); // Location header vs row
    expect(find.text('Remote'), findsOneWidget);
    expect(find.text('\$160,000'), findsOneWidget);
    expect(find.text('Interviewing next week'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);

    // Navigate back to Dashboard
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Job Application Tracker'), findsOneWidget);
  });
}
