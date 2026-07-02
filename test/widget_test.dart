import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persist_weather/main.dart';

void main() {
  testWidgets('Weather view high fidelity load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Initially, it should start in loading state as fetchWeather is called in the viewmodel constructor.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the simulated delay (500ms) to complete and render the UI.
    await tester.pump(const Duration(milliseconds: 600));

    // Verify that Montreal weather details are rendered.
    expect(find.text('Montreal'), findsOneWidget);
    expect(find.text('19°'), findsWidgets);
    expect(find.text('Mostly Clear'), findsOneWidget);
  });
}
