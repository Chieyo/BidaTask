

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bidatask/data/repositories/chat_repository_impl.dart';
import 'package:bidatask/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(chatRepository: ChatRepositoryImpl()));

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and create a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
