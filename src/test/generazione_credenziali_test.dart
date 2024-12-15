import 'dart:convert';
import 'dart:math';
import 'package:civiconnect/gestione_admin/gestione_admin_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:string_similarity/string_similarity.dart';

class FakeAdminManagementController extends Fake implements AdminManagementController {
  @override
  Future<String> generateCredentials(Map<String, String> selectedMunicipality, String adminPassword, String emailComune) async {
    String municipalityEmailPart = selectedMunicipality['Comune']!.toLowerCase().replaceAll(' ', '');
    String emailGen = 'comune.$municipalityEmailPart@anci.gov';
    String passwordGen = generatePassword();

    validateCredentialsGenerated(emailGen, passwordGen);

    return 'Credenziali generate con successo';
  }

  @override
  void validateCredentialsGenerated(String email, String password) {
    String? emailError = validateEmail(email);
    String? passwordError = validatePassword(password);

    if (emailError != null || passwordError != null) {
      throw ('Errore nella generazione delle credenziali');
    }
  }

  @override
  String generatePassword() {
    const length = 15;
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const special = '!@#\$%&*?';

    const allChars = uppercase + lowercase + numbers + special;
    final rand = Random.secure();

    String password = '';
    password += uppercase[rand.nextInt(uppercase.length)];
    password += lowercase[rand.nextInt(lowercase.length)];
    password += numbers[rand.nextInt(numbers.length)];
    password += special[rand.nextInt(special.length)];

    for (int i = 4; i < length; i++) {
      password += allChars[rand.nextInt(allChars.length)];
    }

    // Mix character of password
    List<String> passwordChars = password.split('');
    passwordChars.shuffle();
    return passwordChars.join();
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
  _testGenerateCredentials(description: 'TC_4.0_6', emailGen: 'comune.roma!?@anci.gov', passwordGen: 'validP4ssword#',
      expected: 'Errore nella generazione delle credenziali', reason: 'Credenziale Email generata non valida');

  /// Test Case TC_4.0_7
  _testGenerateCredentials(description: 'TC_4.0_7', emailGen: 'comune.romaanci.gov', passwordGen: 'validP4ssword#',
      expected: 'Errore nella generazione delle credenziali', reason: 'Credenziale Email generata non valida');

  /// Test Case TC_4.0_8
  _testGenerateCredentials(description: 'TC_4.0_8', emailGen: 'comune.roma@anci.gov', passwordGen: 'Password#',
      expected: 'Errore nella generazione delle credenziali', reason: 'Credenziale Password generata non valida');

  //Check Municipality
  /// Test Case TC_4.0_9
  _testExistsInDatabase(description: 'TC_4.0_9', inputComune: 'FISCIANO', expected: true, reason: 'Comune non presente nel database');

  /// Test Case TC_4.0_10
  _testCorrectGenerateCredentials(description: 'TC_4.0_10', inputEmail: 'correct.format@mail.com', inputPassword: 'validP4ssword#', inputComune: 'ROMA',
      expected: 'Credenziali generate con successo', reason: 'Credenziali generate correttamente');
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
    bool validationResult = await localController.validateAdminPassword(input);
    expect(validationResult, expected, reason: reason);
  });
}

void _testGenerateCredentials({required String description, required String emailGen, required String passwordGen,
  required String expected, String? reason}) {
  testWidgets(description, (tester) async {
    final localController = FakeAdminManagementController();

    // Generazione credenziali
    try {
      localController.validateCredentialsGenerated(emailGen, passwordGen);
      expect(null, expected, reason: reason);
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

void _testCorrectGenerateCredentials ({required String description, required String inputEmail, required String inputPassword, required String inputComune,
  required String expected, String? reason}) {
  testWidgets(description, (tester) async {
    final localController = FakeAdminManagementController();

    String message = await localController.generateCredentials({'Comune': inputComune, 'Provincia': 'RM'}, inputPassword, inputEmail);

    expect(message, expected, reason: reason);
  });
}