import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persist_weather/main.dart';

void main() {
  testWidgets('App smoke test — renders without crashing', (WidgetTester tester) async {
    // Initialize mock SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build the app and trigger a frame.
    await tester.pumpWidget(MyApp(prefs: prefs));

    // Verify the app renders (title or loading indicator should be present)
    // The app will show empty state or loading state on first launch
    expect(find.byType(MyApp), findsOneWidget);
  });
}
