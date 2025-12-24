// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zubid_app/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ZubidApp());

    // Verify app loads (shows loading indicator initially)
    expect(find.byType(ZubidApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait a bit for initial loading
    await tester.pump(const Duration(seconds: 1));

    // The app should still be functional even if network calls fail
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
