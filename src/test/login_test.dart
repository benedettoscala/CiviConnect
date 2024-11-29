// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:civiconnect/user_management/login_utente_gui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (tester) async {
    //Build our app and trigger a frame.
    await tester.pumpWidget(
        MaterialApp(
            home: const LoginUtenteGUI())
    );

    // Verify the login button is present
    expect(find.text('Login'), findsOneWidget);
    // Verify the email field is present
    expect(find.text('Email'), findsOneWidget);
    // Verify the password field is present
    expect(find.text('Password'), findsOneWidget);


    // Tap the login button and trigger a frame.
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify that the login button is still present
    expect(find.text('Login'), findsOneWidget, reason: 'The login button is still present on void credentials');
    // Verify that the email field is still present
    expect(find.text('Email'), findsOneWidget, reason: 'The email field is still present on void credentials');
    // Verify that the password field is still present
    expect(find.text('Password'), findsOneWidget, reason: 'The password field is still present on void credentials');


  });
}
