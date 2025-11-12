import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booknest/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BookNestApp());

    // Verify that the app starts with the welcome screen
    expect(find.text('Your Next Chapter\nAwaits'), findsOneWidget);
  });
}
