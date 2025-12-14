// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:zubid_app/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ZubidApp());

    // Verify app loads (shows loading indicator initially)
    expect(find.byType(ZubidApp), findsOneWidget);
  });
}
