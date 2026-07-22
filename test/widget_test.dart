import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_2306089/main.dart';

void main() {
  testWidgets('PremiumApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PremiumApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
