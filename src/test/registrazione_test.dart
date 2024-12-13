import 'package:civiconnect/user_management/registrazione_utente_gui.dart';
import 'package:civiconnect/user_management/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test Case fot the RegistrazioneUtente
/// Mainly tests the presence of the registration button, email field and password field
///
/// TC_3.0_1: Empty e-mail field Expected: Registration fails
/// TC_3.0_2: Non admissible special chars: Registration fails
/// TC_3.0_3: Email with missing required elements (i.e '@', '.')
/// TC_3.0_4: Password with less than 6 characters: Registration fails
/// TC_3.0_5: Password without special characters: Registration fails
/// TC_3.0_6: Email in system: Registration fails
/// TC_3.0_7: Name length equal to 0: Registration fails
/// TC_3.0_8: Name have numbers and special characters: Registration fails
/// TC_3.0_9: Surname length equal to 0: Registration fails
/// TC_3.0_10: Surname have numbers and special characters: Registration fails
/// TC_3.0_11: City length equal to 0: Registration fails
/// TC_3.0_12: City have numbers and special characters: Registration fails
/// TC_3.0_13: City isn't in the list: Registration fails
/// TC_3.0_14: CAP don't have 5 numbers: Registration fails
/// TC_3.0_15: CAP have letters or special characters: Registration fails
/// TC_3.0_16: CAP isn't in the list: Registration fails
/// TC_3.0_17: Via length equal to 0: Registration fails
/// TC_3.0_18: CIVICO length equal to 0: Registration fails
/// TC_3.0_19: CIVICO have letters or special characters: Registration fails
/// TC_3.0_20: Success registration: Registration is Accepted
///
/// dart run build_runner build
///

class FakeUserManagementController extends Fake
    implements UserManagementController {
  @override
  Future<bool> register(BuildContext context,
      {required String email,
      required String password,
      required String name,
      required String surname,
      required Map<String, String> address,
      required String city,
      required String cap}) {
    if (email == 'present@gmail.com') {
      return Future.value(false);
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const Placeholder()));
      return Future.value(true);
    }
  }

  @override
  Future<bool> isCapMatchingCityAPI(String cap, String city) {
    if (cap == '84084' && city == 'Fisciano') {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }
}

void main() {
  _testField(
      description: 'TC_3.0_1',
      email: '',
      password: 'Valid1@Password',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '84084',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23',
      expected: 'This field requires a valid email address.',
      isValid: false,
      testKey: 'emailField');

  _testField(
      description: 'TC_3.0_2',
      email: 'valid@/email.com',
      password: 'Valid1@Password',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '84084',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23',
      expected: 'This field requires a valid email address.',
      isValid: false,
      testKey: 'emailField');

  _testField(
      description: 'TC_3.0_3',
      email: 'validemail.com',
      password: 'Valid1@Password',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '84084',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23',
      expected: 'This field requires a valid email address.',
      isValid: false,
      testKey: 'emailField');

  _testField(
      description: 'TC_3.0_4',
      email: 'valid@email.com',
      password: 'Shor1@',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '84084',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23',
      expected: 'Value must have a length greater than or equal to 8',
      isValid: false,
      testKey: 'passwordField');

  _testField(
      description: 'TC_3.0_5',
      email: 'present@gmail.com',
      password: 'Valid1@Password',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '84084',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23',
      expected: 'Invalid email or password',
      isValid: false);

  _testField(
      description: 'TC_3.0_6',
      email: 'valid@email.com',
      password: 'longpassword1@',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '84084',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23',
      expected: 'Value must contain at least 1 uppercase characters.',
      isValid: false,
      testKey: 'passwordField');

  _testField(
      description: 'TC_3.0_7',
      email: 'valid@email.com',
      password: 'Right1@Password',
      name: '',
      surname: 'ValidUsername',
      cap: '84084',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23',
      expected: 'Il nome è obbligatorio',
      isValid: false,
      testKey: 'nameField');

  _testField(
      description: 'TC_3.0_8',
      email: 'valid@email.com',
      password: 'Right1@Password',
      name: 'ValidName1',
      surname: 'ValidUsername',
      cap: '84084',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23',
      expected: 'Il nome può contenere solo caratteri alfabetici',
      isValid: false,
      testKey: 'nameField');

  _testField(
      description: 'TC_3.0_9',
      email: 'valid@email.com',
      password: 'Right1@Password',
      name: 'ValidName',
      surname: '',
      cap: '84084',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23',
      expected: 'Il cognome è obbligatorio',
      isValid: false,
      testKey: 'surnameField');

  _testField(
      description: 'TC_3.0_10',
      email: 'valid@email.com',
      password: 'Right1@Password',
      name: 'ValidName',
      surname: 'ValidUsername1',
      cap: '84084',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23',
      expected: 'Il cognome può contenere solo caratteri alfabetici',
      isValid: false,
      testKey: 'surnameField');

  _testField(
      description: 'TC_3.0_11',
      email: 'valid@email.com',
      password: 'Right1@Password',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '84084',
      city: '',
      via: 'Via Roma',
      civico: '23',
      expected: 'La città è obbligatoria',
      isValid: false,
      testKey: 'cityField');

  _testField(
      description: 'TC_3.0_12',
      email: 'valid@email.com',
      password: 'Right1@Password',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '84084',
      city: 'Fisciano1',
      via: 'Via Roma',
      civico: '23',
      expected: 'La città può contenere solo caratteri alfabetici e spazi',
      isValid: false,
      testKey: 'cityField');

  _testField(
      description: 'TC_3.0_13',
      email: 'valid@email.com',
      password: 'Right1@Password',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '84084',
      city: 'Fisc',
      via: 'Via Roma',
      civico: '23',
      expected: 'Il CAP inserito non rispecchia la città',
      isValid: false);

  _testField(
      description: 'TC_3.0_14',
      email: 'valid@email.com',
      password: 'Right1@Password',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '8408',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23',
      expected: 'Il CAP deve contenere esattamente 5 cifre',
      isValid: false,
      testKey: 'capField');

  _testField(
      description: 'TC_3.0_15',
      email: 'valid@email.com',
      password: 'Right1@Password',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '8408A',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23',
      expected: 'Il CAP deve contenere esattamente 5 cifre',
      isValid: false,
      testKey: 'capField');

  _testField(
      description: 'TC_3.0_16',
      email: 'valid@email.com',
      password: 'Right1@Password',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '84085',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23',
      expected: 'Il CAP inserito non rispecchia la città',
      isValid: false);

  _testField(
      description: 'TC_3.0_17',
      email: 'valid@email.com',
      password: 'Right1@Password',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '84084',
      city: 'Fisciano',
      via: '',
      civico: '23',
      expected: 'La via è obbligatoria',
      isValid: false,
      testKey: 'viaField');

  _testField(
      description: 'TC_3.0_18',
      email: 'valid@email.com',
      password: 'Right1@Password',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '84084',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '',
      expected: 'N. Civico obbligatorio',
      isValid: false,
      testKey: 'civicoField');

  _testField(
      description: 'TC_3.0_19',
      email: 'valid@email.com',
      password: 'Right1@Password',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '84084',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23F',
      expected: 'Il numero civico può contenere solo cifre',
      isValid: false,
      testKey: 'civicoField');

  _testField(
      description: 'TC_3.0_20',
      email: 'valid@email.com',
      password: 'Right1@Password',
      name: 'ValidName',
      surname: 'ValidUsername',
      cap: '84084',
      city: 'Fisciano',
      via: 'Via Roma',
      civico: '23',
      expected: '',
      isValid: true);
}

/// Pump Registrazione Widget and Test Environment
/// This method is used to pump the Registration Widget and test the environment
Future<void> _pumpWidgetAndTestEnv({required WidgetTester tester}) async {
  //Build our app and trigger a frame.
  final localController = FakeUserManagementController();
  await tester.pumpWidget(
      MaterialApp(home: RegistrazioneUtenteGui(controller: localController)));

  // Verify the Registration elements are present
  await _checkIsRegistrationPage(tester);
}

/// Checks for Registration Page Elements: Registration Button, Email Field, Password Field.
///
/// Async test method
Future<void> _checkIsRegistrationPage(WidgetTester tester) async {
  // Verify that the Registration button is still present
  expect(find.text('Registrati'), findsOneWidget,
      reason: 'The Registration button is (still) present');
  // Verify that the email field is still present
  expect(find.text('Email'), findsOneWidget,
      reason: 'The email field is (still) present');
  // Verify that the password field is still present
  expect(find.text('Password'), findsOneWidget,
      reason: 'The password field is (still) present');
}

void _testField(
    {required String description,
    required String email,
    required String password,
    required String name,
    required String surname,
    required String city,
    required String cap,
    required String via,
    required String civico,
    required String expected,
    String? reason,
    String? testKey,
    bool isValid = false}) {
  testWidgets('Registration: $description', (tester) async {
    // Load Registration Widget and Test Environment
    await _pumpWidgetAndTestEnv(tester: tester);

    // Insert text in the email field
    // Tested input is injected here
    await tester.enterText(find.byKey(const Key('emailField')), email);
    await tester.enterText(find.byKey(const Key('passwordField')), password);
    await tester.enterText(find.byKey(const Key('nameField')), name);
    await tester.enterText(find.byKey(const Key('surnameField')), surname);
    await tester.enterText(find.byKey(const Key('cityField')), city);
    await tester.enterText(find.byKey(const Key('capField')), cap);
    await tester.enterText(find.byKey(const Key('viaField')), via);
    await tester.enterText(find.byKey(const Key('civicoField')), civico);
    // Tap the Registration button and trigger a frame.

    await tester.dragUntilVisible(
      find.byKey(const Key('registerButton')), // what you want to find
      find.byType(SingleChildScrollView), // widget you want to scroll
      const Offset(0, 50), // delta to move
    );
    await tester.tap(find.text('Registrati'));
    await tester.pump();
/*
    final emailState = tester
        .state<FormBuilderFieldState>(find.byKey(Key('emailField')))
        .errorText;
    final passwordState = tester
        .state<FormBuilderFieldState>(find.byKey(Key('passwordField')))
        .errorText;
    final nameState = tester
        .state<FormBuilderFieldState>(find.byKey(Key('nameField')))
        .errorText;
    final surnameState = tester
        .state<FormBuilderFieldState>(find.byKey(Key('surnameField')))
        .errorText;
    final cityState = tester
        .state<FormBuilderFieldState>(find.byKey(Key('cityField')))
        .errorText;
    final capState = tester
        .state<FormBuilderFieldState>(find.byKey(Key('capField')))
        .errorText;
    final viaState = tester
        .state<FormBuilderFieldState>(find.byKey(Key('viaField')))
        .errorText;
    final civicoState = tester
        .state<FormBuilderFieldState>(find.byKey(Key('civicoField')))
        .errorText;
*/
    if (isValid) {
      /// all work fine. nice job
      await tester.pumpAndSettle();
      expect(find.text('Registrati'), findsNothing);
    } else {
      await _checkIsRegistrationPage(tester);
      if (testKey == null) {
        expect(find.text(expected), findsOneWidget,
            reason: reason ?? 'Login failed for invalid credentials');
      } else {
        final fieldState =
            tester.state<FormBuilderFieldState>(find.byKey(Key(testKey)));
        //Test expected error message
        expect(fieldState.errorText, expected);
      }
    }
  });
}
