import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_back4app/main.dart';

void main() {
  testWidgets('auth screen shows login controls', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AuthScreen(onSignedIn: (_) {})));

    expect(find.text('Task Manager'), findsOneWidget);
    expect(find.text('Login'), findsAtLeastNWidgets(1));
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byIcon(Icons.login), findsOneWidget);
  });
}
