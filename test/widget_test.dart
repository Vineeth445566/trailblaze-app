// Basic smoke test for TrailBlaze.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trail_blaze/main.dart';

void main() {
  testWidgets('App launches with bottom navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TrailBlazeApp());
    // pumpAndSettle() never settles because the map tile layer keeps
    // retrying in the sandboxed test env; pump fixed frames instead.
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('TrailBlaze'), findsOneWidget);
    expect(find.byIcon(Icons.explore), findsOneWidget);
    expect(find.text('Record'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });
}
