import 'package:flutter_test/flutter_test.dart';
import 'package:job_application_tracker/app/app.dart';

void main() {
  testWidgets('App renders main navigation and switches tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    // Verify Dashboard is initially visible
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Applications'), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Initial Dashboard content check
    expect(find.text('Job Application Tracker'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);

    // Tap Applications tab
    await tester.tap(find.text('Applications'));
    await tester.pumpAndSettle();
    expect(find.text('My Applications'), findsOneWidget);

    // Tap Statistics tab
    await tester.tap(find.text('Statistics'));
    await tester.pumpAndSettle();
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('No Statistics Available'), findsOneWidget);

    // Tap Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Preferences Coming Soon'), findsOneWidget);

    // Return to Dashboard tab
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget);
  });
}
