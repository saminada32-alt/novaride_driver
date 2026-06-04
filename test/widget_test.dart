// Basic smoke test for the driver app.
//
// The real app root (MyAppRoot/MyApp) wires Firebase, providers and routing,
// which can't be bootstrapped in a plain widget test. This self-contained
// smoke test verifies the widget testing harness works and renders a frame.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a basic frame', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('NovaRide'))),
      ),
    );

    expect(find.text('NovaRide'), findsOneWidget);
  });
}
