import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:systex_frotas/app.dart';

void main() {
  testWidgets('app boot renders splash loader', (WidgetTester tester) async {
    await tester.pumpWidget(const SystexFrotasApp());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
