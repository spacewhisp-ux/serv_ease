import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:serv_ease/app/app.dart';

void main() {
  testWidgets('app shows splash on startup', (WidgetTester tester) async {
    await tester.pumpWidget(const ServEaseApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
