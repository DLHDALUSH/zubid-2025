// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zubid_mobile/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ZubidApp(),
      ),
    );

    // Verify the app loads without crashing
    // The app uses router, so we just verify it renders
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Check that we have a MaterialApp somewhere in the widget tree
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
