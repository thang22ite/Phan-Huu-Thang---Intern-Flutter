import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:university_network_graph/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UniversityNetworkApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
