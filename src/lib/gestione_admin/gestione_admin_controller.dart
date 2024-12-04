import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'gestione_admin_dao.dart';



class AdminManagementController {
  /// The page to navigate to after a successful login.
  final Widget redirectPage;

  /// Constructs a `UserManagementController` instance.
  ///
  /// Parameters:
  /// - [redirectPage]: The target page to navigate to after a successful login.
  AdminManagementController({required this.redirectPage});

  //-------- Generate Credentials for Municipality --------

  final AdminManagementDAO _dao = AdminManagementDAO();

  /// Load the list of municipalities from JSON.
  Future<List<Map<String, String>>> loadMunicipalities() async {
    String data = await rootBundle.loadString('assets/files/comuni-localita-cap-italia.json');
    Map<String, dynamic> jsonResult = json.decode(data);

    print('JSON Result: $jsonResult'); // Debug

    List<dynamic> municipalitiesList = jsonResult["Sheet 1 - comuni-localita-cap-i"];
    List<Map<String, String>> allMunicipalities = municipalitiesList
        .map((comune) => {
      'Comune': comune["Comune Localita’"].toString(),
      'Provincia': comune["Provincia"].toString(),
    })
        .toSet()
        .toList(); // Rimuove duplicati

    print('All Municipalities Length: ${allMunicipalities.length}'); // Debug

    return allMunicipalities;
  }

  /// Filters the list of municipalities based on the search query.
  List<Map<String, String>> filterMunicipalities(
      List<Map<String, String>> allMunicipalities, String query) {
    List<Map<String, String>> suggestions = allMunicipalities
        .where((comune) =>
        comune['Comune']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Only show the first 7 suggestions
    if (suggestions.length > 7) {
      suggestions = suggestions.sublist(0, 7);
    }

    return suggestions;
  }

  /// Checks if the municipality exists in the database.
  Future<bool> municipalityExistsInDatabase(String comune) async {
    return await _dao.municipalityExistsInDatabase(comune);
  }

  /// Generates credentials for the selected municipality.
  Future<Map<String, String>> generateCredentials(
      Map<String, String> selectedMunicipality) async {
    String municipalityEmailPart = selectedMunicipality['Comune']!.toLowerCase().replaceAll(' ', '');
    String email = 'comune.$municipalityEmailPart@anci.gov';
    String password = generatePassword();

    // Save credentials to the database
    await _dao.saveCredentialsToDatabase(email, password, selectedMunicipality);

    return {'email': email, 'password': password};
  }

  /// Generate a random password for the municipality.
  String generatePassword() {
    const length = 15;
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const special = '!@#\$%&*?';

    final allChars = uppercase + lowercase + numbers + special;
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
}
