import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medvita/main.dart';

void main() {
  testWidgets('MedVita smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MedVitaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
