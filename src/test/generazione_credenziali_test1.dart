import 'dart:convert';
import 'package:civiconnect/gestione_admin/gestione_admin_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:string_similarity/string_similarity.dart';

class FakeAdminManagementController extends Fake implements AdminManagementController {
  @override
  Future<Map<String, String>> generateCredentials(Map<String, String> selectedMunicipality, String adminPassword, String emailComune) async {
    String municipalityEmailPart = selectedMunicipality['Comune']!.toLowerCase().replaceAll(' ', '');
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

  @override
  Future<bool> validateAdminPassword(String password) {
    if (password == 'validP4ssword#') {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }
}

void main() {
  // Check Email Municipality
  /// Test Case TC_4.0_1
  _testEmail(description: 'TC_4.0_1', input: 'string?!@thismail.com', expected: 'Inserisci un indirizzo email valido',
      reason: 'Email ha un carattere speciale');

  /// Test Case TC_4.0_2
  _testEmail(description: 'TC_4.0_2', input: 'Stringthismail.com', expected: 'Inserisci un indirizzo email valido',
      reason: 'Email con elementi mancanti');

  // Check Password Admin
  /// Test Case TC_4.0_3
  _testPassword(description: 'TC_4.0_3', input: 's#0rT', expected: 'La password deve contenere almeno 8 caratteri',
      reason: 'Password troppo corta');

  /// Test Case TC_4.0_4
  _testPassword(description: 'TC_4.0_4', input: 'noSpeci4lChar', expected: 'La password deve contenere almeno un carattere speciale',
      reason: 'Password senza caratteri speciali');

  /// Test Case TC_4.0_5
  _testValidationAdminPassword(description: 'TC_4.0_5', input: 'invalidP4ssword#', expected: false, reason: 'Password Admin non corretta');

  //Check credentials generation
  /// Test Case TC_4.0_6
  _testGenerateCredentials(description: 'TC_4.0_6', inputEmail: 'correct.format@mail.com', inputPassword: 'validP4ssword#', inputComune: 'ROMA',
      expected: 'Errore nella generazione delle credenziali', reason: 'Credenziale Email generata non valida');

  /// Test Case TC_4.0_7
  _testGenerateCredentials(description: 'TC_4.0_7', inputEmail: 'correct.format@mail.com', inputPassword: 'validP4ssword#', inputComune: 'ROMA',
      expected: 'Errore nella generazione delle credenziali', reason: 'Credenziale Email generata non valida');

  /// Test Case TC_4.0_8
  _testGenerateCredentials(description: 'TC_4.0_8', inputEmail: 'correct.format@mail.com', inputPassword: 'validP4ssword#', inputComune: 'ROMA',
      expected: 'Errore nella generazione delle credenziali', reason: 'Credenziale Password generata non valida');

  //Check Municipality
  /// Test Case TC_4.0_9
  _testExistsInDatabase(description: 'TC_4.0_9', inputComune: 'FISCIANO', expected: false, reason: 'Comune non presente nel database');

  /// Test Case TC_4.0_10
  _testGenerateCredentials(description: 'TC_4.0_10', inputEmail: 'correct.format@mail.com', inputPassword: 'validP4ssword#', inputComune: 'ROMA',
      expected: '', reason: 'Credenziale Password generata non valida');
}

void _testEmail({required String description, required String input, required String expected, String? reason}) {
  testWidgets(description, (tester) async {
    final localController = FakeAdminManagementController();

    // Validazione
    String? validationResult = localController.validateEmail(input);
    expect(validationResult, expected, reason: reason);
  });
}

void _testPassword({required String description, required String input, required String expected, String? reason}) {
  testWidgets(description, (tester) async {
    final localController = FakeAdminManagementController();

    // Validazione
    String? validationResult = localController.validatePassword(input);
    expect(validationResult, expected, reason: reason);
  });
}

void _testValidationAdminPassword({required String description, required String input, required bool expected, String? reason}) {
  testWidgets(description, (tester) async {
    final localController = FakeAdminManagementController();

    // Validazione
    String? validationResult = localController.validatePassword(input);
    if (validationResult != null) {
      expect(validationResult, expected, reason: reason);
    } else {
      expect(validationResult, expected, reason: reason);
    }
  });
}

void _testGenerateCredentials({required String description, required String inputEmail, required String inputPassword, required String inputComune,
  required String expected, String? reason}) {
  testWidgets(description, (tester) async {
    final localController = FakeAdminManagementController();

    // Generazione credenziali
    try {
    Map<String, String> credenziali = await localController.generateCredentials({'Comune': inputComune}, inputPassword, inputEmail);
      expect(credenziali, expected, reason: reason);
    } catch (e) {
      expect(e, expected, reason: reason);
    }
  });
}

void _testExistsInDatabase({required String description, required String inputComune, required bool expected, String? reason}) {
  testWidgets(description, (tester) async {
    final localController = FakeAdminManagementController();

    // Verifica esistenza comune
    bool exists = await localController.municipalityExistsInDatabase(inputComune);
    expect(exists, expected, reason: reason);
  });
}