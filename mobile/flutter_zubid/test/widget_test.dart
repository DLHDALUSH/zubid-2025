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

    // Smoke test: ensure the app can render at least one frame.
    // Avoid pumpAndSettle here because the app may have ongoing animations
    // (e.g., splash screen timers) that prevent settling.
    await tester.pump();

    // Check that we have a MaterialApp somewhere in the widget tree
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
