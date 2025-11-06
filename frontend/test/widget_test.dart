import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bidatask/main.dart';

void main() {
  testWidgets('App starts and shows task manager screen', (WidgetTester tester) async {
    // create a frame
    await tester.pumpWidget(const BidaTaskApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Task Manager'), findsOneWidget);
  });
}
