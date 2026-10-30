import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_annotator/main.dart';

void main() {
  testWidgets('VibeAnnotatorApp smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const VibeAnnotatorApp());
    expect(find.text('VIBE'), findsOneWidget);
    expect(find.text('ANNOTATOR'), findsOneWidget);
  });
}
