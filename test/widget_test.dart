import 'package:flutter_test/flutter_test.dart';
import 'package:job_application_tracker/app/app.dart';

void main() {
  testWidgets('App renders dashboard screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Job Application Tracker'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('No Applications Yet'), findsOneWidget);
  });
}
