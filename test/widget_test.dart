// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:anim_graphr/data.dart';
import 'package:anim_graphr/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('animation smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(App());

    expect(find.text(curves.first.name), findsOneWidget);
    expect(find.byKey(Key('curveGraph')), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1000 ms'), findsNothing);
    expect(find.text('1100 ms'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(find.text('1000 ms'), findsOneWidget);
    expect(find.text('1100 ms'), findsNothing);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
  });
}
