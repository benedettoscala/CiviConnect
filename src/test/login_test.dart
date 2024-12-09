// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:civiconnect/home_page.dart';
import 'package:civiconnect/user_management/login_utente_gui.dart';
import 'package:civiconnect/user_management/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';


/// Test Case fot the LoginUtente
/// Mainly tests the presence of the login button, email field and password field
///
/// TC_1.0_1: Empty e-mail field Expected: Login fails
/// TC_1.0_2: Non admissible special chars: Login fails
/// TC_1.0_3: Email with missing required elements (i.e '@', '.')
/// TC_1.0_4: Password with less than 6 characters: Login fails
/// TC_1.0_5: Password without special characters: Login fails
/// TC_1.0_6: Email not in system: Login fails
/// TC_1.0_7: Password not in system: Login fails
/// TC_1.0_8: Email and Password in system: Login is Accepted
/// dart run build_runner build
///

class FakeUserManagementController extends Fake implements UserManagementController {
  @override
  Future<bool> login(BuildContext context, {required String email, required String password}) {
    if(email == 'valid.email@mail.com' && password == 'validP4ssword#'){
      //push to HomePage if login is successful
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Placeholder()));
      return Future.value(true);
    } else {
      return Future.value(false);
    }
    //return Future.value(email == 'valid.email@mail.com' && password == 'validP4ssword#');
  }
}

@GenerateMocks([UserManagementController])
void main() {
  // Check Email
  /// Test Case TC_1.0_1
  _testEmail(description: 'TC_1.0_1', input: '', expected: 'Value must have a length less than or equal to 255', reason: 'Email field must respect length constraints');

  /// Test Case TC_1.0_2
  _testEmail(description: 'TC_1.0_2',input: 'string??@thismail.com', expected:'Inserito carattere non valido', reason: 'Email field must have only allowed chars');

  /// Test Case TC_1.0_3
  _testEmail(description: 'TC_1.0_3', input: 'stringemail.com', expected: 'This field requires a valid email address.', reason: 'Email field must have required chars');

  // Check Password
  /// Test Case TC_1.0_4
  _testPassword(description: 'TC_1.0_4', input: 's#0rT', expected: 'Value must have a length greater than or equal to 8', reason: 'Password must respect length constraints');

  /// Test Case TC_1.0_5
  _testPassword(description: 'TC_1.0_5', input: 'noSpeci4lChar', expected: 'Value must contain at least 1 special characters.', reason: 'Password must have required characters due to security standards');

  //Validity Email and Password: In System or Not - Database Stub required
  /// Test Case TC_1.0_6
  _testValidation(description: 'TC_1.0_6', inputEmail: 'correct.format@mail.com', inputPassword: 'validP4ssword#', expected: 'Invalid email or password',
      isValid: false, reason: 'Login failed for invalid email credentials');

  /// Test Case TC_1.0_7
  _testValidation(description: 'TC_1.0_7', inputEmail: 'valid.email@mail.com', inputPassword: 'invalidP4ssword#', expected: 'Invalid email or password',
      isValid: false, reason: 'Login failed for invalid password credentials');

  /// Test Case TC_1.0_8
  _testValidation(description: 'TC_1.0_8', inputEmail: 'valid.email@mail.com', inputPassword: 'validP4ssword#',
      isValid: true, reason: 'Login success with right combination of email and password');

}


/// Testing Email Field
void _testEmail({required String description,  required String input, required String expected, String? reason}){
  testWidgets('Login: $description', (tester) async {

    // Load Login Widget and Test Environment
    await _pumpWidgetAndTestEnv(tester: tester);

    // Insert text in the email field
    // Tested input is injected here
    await tester.enterText(find.bySubtype<FormBuilderTextField>().first, input);
    // Tap the login button and trigger a frame.
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Check we're still in Login Page
    await _checkIsLoginPage(tester);


    // Get form field keys where error messages are saved
    List<GlobalKey<FormBuilderFieldState>> keys = _getFieldKeys();

    //Test expected error message
    expect(keys[0].currentState?.errorText, expected, reason: reason);
    //'Il valore inserito deve avere una lunghezza minore o uguale a 255.'


  });
}


/// Testing Password Field
void _testPassword({required String description, required String input, required String expected, String? reason}){
  testWidgets('Login $description', (tester) async {

    // Load Login Widget and Test Environment
    await _pumpWidgetAndTestEnv(tester: tester);


    //await tester.tap(find.text('Login'));
    await tester.enterText(find.bySubtype<FormBuilderTextField>().first, 'correctly@formatted.com');
    await tester.enterText(find.bySubtype<FormBuilderTextField>().at(1), input);
    // Tap the login button and trigger a frame.
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Still in Login Page

    // Check we're still in Login Page
    await _checkIsLoginPage(tester);

    // Get form field keys where error messages are saved
    List<GlobalKey<FormBuilderFieldState>> keys = _getFieldKeys();

    //Test expected error message
    expect(keys[1].currentState?.errorText, expected, reason: reason);
    //'Il valore inserito deve avere una lunghezza minore o uguale a 255.'

  });
}


/// Testing Validation of Email and Password
/// This method is used to test the validation of the email and password fields
///
/// A stub of the UserManagementController is used to simulate the login process
Future<void> _testValidation({required String description, required String inputEmail, required String inputPassword, required bool isValid,
  String? expected, String? reason, UserManagementController? controller}) async {
  testWidgets('Login: $description', (tester) async {

    final localController = controller ?? FakeUserManagementController();
    // Load Login Widget and Test Environment
    await _pumpWidgetAndTestEnv(tester: tester, controller: localController);

    // Insert text in the email field
    // Tested input is injected here
    await tester.enterText(find.bySubtype<FormBuilderTextField>().at(0), inputEmail);
    await tester.enterText(find.bySubtype<FormBuilderTextField>().at(1), inputPassword);


    // Tap the login button and trigger a frame.
    await tester.tap(find.text('Login'));
    await tester.pump();

    if(isValid){
      // Wait for the HomePage to be pushed
      await tester.pumpAndSettle();
      // Check HomePage is pushed
      expect(find.byType(LoginUtenteGUI), findsNothing, reason: 'Login success for valid credentials');
      // Check we're not in Login Page
      expect(find.text('Login'), findsNothing, reason: 'Login button is not present: successful login');

    } else {

      // Check we're still in Login Page
      await _checkIsLoginPage(tester);
      expect(find.text(expected!), findsOneWidget, reason: reason ?? 'Login failed for invalid credentials');
    }
  });
}



/* -------------------------------- GENERIC TESTING AND WIDGET PUMPS ----------------------- */


/// Pump Login Widget and Test Environment
/// This method is used to pump the Login Widget and test the environment
Future<void> _pumpWidgetAndTestEnv({required WidgetTester tester, UserManagementController? controller}) async {
  //Build our app and trigger a frame.
  await tester.pumpWidget(
      MaterialApp(
          home: LoginUtenteGUI(controller: controller,))
  );

  // Verify the login elements are present
  await _checkIsLoginPage(tester);
}


/// Checks for Login Page Elements: Login Button, Email Field, Password Field.
///
/// Async test method
Future<void> _checkIsLoginPage(WidgetTester tester) async {
  // Verify that the login button is still present
  expect(find.text('Login'), findsOneWidget, reason: 'The login button is (still) present');
  // Verify that the email field is still present
  expect(find.text('Email'), findsOneWidget, reason: 'The email field is (still) present');
  // Verify that the password field is still present
  expect(find.text('Password'), findsOneWidget, reason: 'The password field is (still) present');
}


/* ------------------------------- UTILITY METHODS ------------------------------------ */

/// Get the GlobalKeys of the form fields
/// and return them as a list
List<GlobalKey<FormBuilderFieldState>> _getFieldKeys(){
  List<FormBuilderTextField> list = find.bySubtype<FormBuilderTextField>().evaluate().map((el) => el.widget as FormBuilderTextField).toList();
  List<GlobalKey<FormBuilderFieldState>> keys = list.map((widget) => widget.key).cast<GlobalKey<FormBuilderFieldState<FormBuilderField, dynamic>>>().toList();
  //FormBuilderTextField form = find.bySubtype<FormBuilderTextField>().evaluate().first.widget as FormBuilderTextField;
  //GlobalKey<FormBuilderFieldState> key = form.key as GlobalKey<FormBuilderFieldState>;
  return keys;
}