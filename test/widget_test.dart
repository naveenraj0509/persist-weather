import 'package:flutter_test/flutter_test.dart';
import 'package:persist_weather/main.dart';

void main() {
  testWidgets('Weather view smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the initial instructions are shown.
    expect(find.text('Find weather info for any city'), findsOneWidget);
    expect(find.text('Search above to get started'), findsOneWidget);
  });
}
