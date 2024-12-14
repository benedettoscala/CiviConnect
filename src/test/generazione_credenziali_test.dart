import 'dart:convert';

import 'package:civiconnect/gestione_admin/admin_gui.dart';
import 'package:civiconnect/gestione_admin/gestione_admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:string_similarity/string_similarity.dart';

class FakeAdminManagementController extends Fake implements AdminManagementController {
  @override
  Future<Map<String, String>> generateCredentials(
      Map<String, String> selectedMunicipality,
      String adminPassword,
      String emailComune) async {
    String municipalityEmailPart =
    selectedMunicipality['Comune']!.toLowerCase().replaceAll(' ', '');
    String emailGen = 'comune.$municipalityEmailPart@anci.gov';
    String passwordGen = generatePassword();

    if (validateEmail(emailGen) != null || validatePassword(passwordGen) != null) {
      throw ('Errore nella generazione delle credenziali');
    }

    return {'emailGen': emailGen, 'passwordGen': passwordGen};
  }

  @override
  String? validateEmail(String email) {
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Inserisci un indirizzo email valido';
    }
    return null;
  }

  @override
  String? validatePassword(String password) {
    if (password.length < 8) {
      return 'La password deve contenere almeno 8 caratteri';
    }
    if (password.length > 255) {
      return 'La password deve contenere al massimo 255 caratteri';
    }
    if (!RegExp(r'[A-Za-z0-9!@#$%&*?]').hasMatch(password)) {
      return 'La password deve contenere solo lettere, numeri e caratteri speciali';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'La password deve contenere almeno una lettera maiuscola';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'La password deve contenere almeno una lettera minuscola';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'La password deve contenere almeno un numero';
    }
    if (!RegExp(r'[!@#$%&*?]').hasMatch(password)) {
      return 'La password deve contenere almeno un carattere speciale';
    }

    return null;
  }

  @override
  Future<List<Map<String, String>>> loadMunicipalities() async {
    String data = await rootBundle
        .loadString('assets/files/comuni-localita-cap-italia.json');
    Map<String, dynamic> jsonResult = json.decode(data);

    List<dynamic> municipalitiesList =
    jsonResult['Sheet 1 - comuni-localita-cap-i'];
    List<Map<String, String>> allMunicipalities = municipalitiesList
        .map((comune) => {
      'Comune': comune['Comune Localita’'].toString(),
      'Provincia': comune['Provincia'].toString(),
    })
        .toSet()
        .toList(); // Remove duplicates

    return allMunicipalities;
  }

  @override
  List<Map<String, String>> filterMunicipalities(
      List<Map<String, String>> allMunicipalities, String query) {
    if (query.isEmpty) {
      return allMunicipalities;
    }

    // Filter the municipalities that contain the query (case insensitive)
    List<Map<String, String>> filtered = allMunicipalities
        .where((comune) =>
        comune['Comune']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Calculate the similarity score for each municipality compared to the query
    List<Map<String, dynamic>> scored = filtered.map((comune) {
      String name = comune['Comune']!;
      double similarity = StringSimilarity.compareTwoStrings(
          name.toLowerCase(), query.toLowerCase());
      return {
        'comune': comune,
        'similarity': similarity,
        'originalIndex': allMunicipalities.indexOf(comune),
      };
    }).toList();

    // Levenshtein distance is used to calculate similarity
    // Order by decreasing similarity and then by original index for stability
    scored.sort((a, b) {
      int cmp = b['similarity'].compareTo(a['similarity']);
      if (cmp != 0) {
        return cmp;
      }
      return a['originalIndex'].compareTo(b['originalIndex']);
    });

    // Select the top 7 most similar
    List<Map<String, String>> top7 = scored
        .take(7)
        .map<Map<String, String>>(
            (item) => item['comune'] as Map<String, String>)
        .toList();

    // Take the filtered municipalities and remove the top 7 most similar
    filtered = filtered.where((comune) => !top7.contains(comune)).toList();

    // Combine the top 7 and the filtered results
    return [...top7, ...filtered];
  }

  @override
  Future<bool> municipalityExistsInDatabase(String comune) async {
    if (comune == 'FISCIANO') {
      return true;
    } else {
      return false;
    }
  }
}

void main() {
  // Check Email Municipality
  /// Test Case TC_4.0_1
  _testEmail(description: 'TC_4.0_1', input: 'string?!@thismail.com', expected: 'Inserisci un indirizzo email valido',
      reason: 'Email ha un carattere speciale');

  /// Test Case TC_4.0_2
  _testEmail(description: 'TC_4.0_2',input: 'stringemail.com', expected:'Inserisci un indirizzo email valido',
      reason: 'Email deve contenere i caratteri richiesti');

  // Check Password Admin
  /// Test Case TC_4.0_3
  _testPassword(description: 'TC_4.0_3', input: 's#0rt', expected: 'La password deve contenere almento 8 caratteri',
      reason: 'Password deve rispettare i vincoli di lunghezza');

  /// Test Case TC_4.0_4
  _testPassword(description: 'TC_4.0_4', input: 'noSpeci4lChar', expected: 'La password deve contenere almeno un carattere speciale',
      reason: 'Password must respect length constraints');

  /// Test Case TC_4.0_5
  //_testPasswordMock(description: 'TC_4.0_5', input: 'invalidP4ssword#', expected: 'Errore nel salvataggio delle credenziali',
  // reason: 'Password admin non corretta');

  // Check credential generation
  /// Test Case TC_4.0_6
  _testGenerateCredentials(description: 'TC_4.0_6', inputEmail: 'correct.format@mail.com', inputPassword: 'validP4ssword#',
      expected: 'Errore nella generazione delle credenziali', reason: 'Credenziale Email generata non valida');

  /// Test Case TC_4.0_7
  _testGenerateCredentials(description: 'TC_4.0_7', inputEmail: 'correct.format@mail.com', inputPassword: 'validP4ssword#',
      expected: 'Errore nella generazione delle credenziali', reason: 'Credenziale Email generata non valida');

  /// Test Case TC_4.0_8
  _testGenerateCredentials(description: 'TC_4.0_8', inputEmail: 'correct.format@mail.com', inputPassword: 'validP4ssword#',
      expected: 'Errore nella generazione delle credenziali', reason: 'Credenziale Password generata non valida');

  //Check Municipality
  /// Test Case TC_4.0_9
  _testMunicipality(description: 'TC_4.0_9', inputEmail: 'valid.email@mail.com', inputPassword: 'validP4ssword#', input: 'FISCIANO',
      expected: 'Errore nel salvataggio delle credenziali', reason: 'Comune già esistente');

  /// Test Case TC_4.0_10
  _testMunicipality(description: 'TC_4.0_10', inputEmail: 'valid.email@mail.com', inputPassword: 'validP4ssword#', input: 'ROMA',
      expected: 'Credenziali generate con successo', reason: 'Corretto');
}

/// Testing Email Field
void _testEmail({required String description,  required String input, required String expected, String? reason}) {
  testWidgets('Generazione Credenziali: $description', (tester) async {
    final localController = FakeAdminManagementController();
    await _pumpWidgetAndTestEnv(tester: tester, controller: localController);

    await _insertMunicipality(tester: tester, input: 'FISCIANO');

    // Insert text in the email field
    // Tested input is injected here
    await tester.enterText(find.bySubtype<FormBuilderTextField>().at(0), input);
    await tester.enterText(find.bySubtype<FormBuilderTextField>().at(1), 'validP4ssword#');
    await tester.tap(find.text('Conferma'));
    await tester.pump();

    expect(find.text(expected), findsOneWidget, reason: reason);
  });
}

void _testPassword({required String description,  required String input, required String expected, String? reason}){
  testWidgets('Generazione Credenziali: $description', (tester) async {
    final localController = FakeAdminManagementController();
    await _pumpWidgetAndTestEnv(tester: tester, controller: localController);

    await _insertMunicipality(tester: tester, input: 'FISCIANO');

    // Insert text in the password field
    // Tested input is injected here
    await tester.enterText(find.bySubtype<FormBuilderTextField>().at(0), 'string@email.com');
    await tester.enterText(find.bySubtype<FormBuilderTextField>().at(1), input);
    await tester.tap(find.text('Conferma'));
    await tester.pump();

    List<GlobalKey<FormBuilderFieldState>> keys = _getFieldKeys();

    //Test expected error message
    expect(keys[1].currentState?.errorText, expected, reason: reason);
    });
}

void _testMunicipality({required String description,  required String inputEmail, required String inputPassword, required String input, required String expected, String? reason}){
  testWidgets('Generazione Credenziali: $description', (tester) async {
    final localController = FakeAdminManagementController();

    // Load Admin Widget and Test Environment
    await _pumpWidgetAndTestEnv(tester: tester, controller: localController);

    // Insert text in the municipality field
    await tester.enterText(find.bySubtype<FormBuilderTextField>().first, input);
    await tester.tap(find.text('Genera Credenziali'));
    await tester.pump();

    // Get form field keys where error messages are saved
    List<GlobalKey<FormBuilderFieldState>> keys = _getFieldKeys();

    //Test expected error message
    expect(keys[3].currentState?.errorText, expected, reason: reason);
  });
}

void _testGenerateCredentials({required String description, required String inputEmail, required String inputPassword, required expected, String? reason}){
  testWidgets('Generazione Credenziali: $description', (tester) async {
    final localController = FakeAdminManagementController();
    await _pumpWidgetAndTestEnv(tester: tester, controller: localController);

    await _insertMunicipality(tester: tester, input: 'FISCIANO');

    // Insert text in the email field
    await tester.enterText(find.bySubtype<FormBuilderTextField>().at(0), inputEmail);
    await tester.enterText(find.bySubtype<FormBuilderTextField>().at(1), inputPassword);
    await tester.tap(find.text('Conferma'));
    await tester.pump();

    // Get form field keys where error messages are saved
    List<GlobalKey<FormBuilderFieldState>> keys = _getFieldKeys();

    //Test expected error message
    expect(keys[2].currentState?.errorText, expected, reason: reason);
  });
}

/* -------------------------------- GENERIC TESTING AND WIDGET PUMPS ----------------------- */


/// Pump Admin Widget and Test Environment
/// This method is used to pump the Admin Widget and test the environment
Future<void> _pumpWidgetAndTestEnv({required WidgetTester tester, AdminManagementController? controller}) async {
  //Build our app and trigger a frame.
  await tester.pumpWidget(
      MaterialApp(
          home: AdminHomePage(controller: controller))
  );

  // Verify the admin elements are present
  await _checkIsAdminPage(tester);
}

/// Checks for Admin Page Elements: Cerca Comune Field.
///
/// Async test method
Future<void> _checkIsAdminPage(WidgetTester tester) async {
  // Verify that the Cerca Comune field is still present
  expect(find.text('Cerca Comune'), findsOneWidget, reason: 'The Cerca Comune field is (still) present');
}

/* ------------------------------- UTILITY METHODS ------------------------------------ */

/// Get the GlobalKeys of the form fields
/// and return them as a list
List<GlobalKey<FormBuilderFieldState>> _getFieldKeys(){
  List<FormBuilderTextField> list = find.bySubtype<FormBuilderTextField>().evaluate().map((el) => el.widget as FormBuilderTextField).toList();
  List<GlobalKey<FormBuilderFieldState>> keys = list.map((widget) => widget.key).cast<GlobalKey<FormBuilderFieldState<FormBuilderField, dynamic>>>().toList();

  return keys;
}

/// Insert Municipality
Future<void> _insertMunicipality({required WidgetTester tester, required String input}) async {
    await tester.enterText(find.bySubtype<FormBuilderTextField>().at(0), input);
    await tester.tap(find.text(input));
    await tester.pump();
    await tester.tap(find.text('Genera Credenziali'));
    await tester.pump();
}