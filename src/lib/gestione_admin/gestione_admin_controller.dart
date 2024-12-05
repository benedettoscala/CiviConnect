import 'dart:convert';
import 'dart:math';

import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:flutter/services.dart';
import 'package:string_similarity/string_similarity.dart';

import 'gestione_admin_dao.dart';



class AdminManagementController {
  //-------- Generate Credentials for Municipality --------

  final AdminManagementDAO _daoAdmin = AdminManagementDAO();
  final UserManagementDAO _daoUser = UserManagementDAO();

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
        .toList(); // Remove duplicates

    return allMunicipalities;
  }

  List<Map<String, String>> filterMunicipalities(
      List<Map<String, String>> allMunicipalities, String query) {
    if (query.isEmpty) {
      return allMunicipalities;
    }

    // Filtra i comuni che contengono la query (case insensitive)
    List<Map<String, String>> filtered = allMunicipalities
        .where((comune) =>
        comune['Comune']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Calcola il punteggio di similarità per ogni comune rispetto alla query
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

    // Ordina per similarità decrescente e poi per indice originale per stabilità
    scored.sort((a, b) {
      int cmp = b['similarity'].compareTo(a['similarity']);
      if (cmp != 0) return cmp;
      return a['originalIndex'].compareTo(b['originalIndex']);
    });

    // Prendi i primi 7 più simili
    List<Map<String, String>> top7 = scored
        .take(7)
        .map<Map<String, String>>((item) => item['comune'] as Map<String, String>)
        .toList();

    // Prendi i comuni filtrati e rimuovi i primi 7
    filtered = filtered
        .where((comune) => !top7.contains(comune))
        .toList();

    // Combina i risultati
    return [...top7, ...filtered];
  }

  /// Checks if the municipality exists in the database.
  Future<bool> municipalityExistsInDatabase(String comune) async {
    return await _daoAdmin.municipalityExistsInDatabase(comune);
  }

  /// Generates credentials for the selected municipality.
  Future<Map<String, String>> generateCredentials(
      Map<String, String> selectedMunicipality) async {
    String municipalityEmailPart = selectedMunicipality['Comune']!.toLowerCase().replaceAll(' ', '');
    String email = 'comune.$municipalityEmailPart@anci.gov';
    String password = generatePassword();

    // Save credentials to the database
    await _daoAdmin.saveCredentialsToDatabase(email, password, selectedMunicipality);

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

  /// Logout the current user.
  Future<void> logOut() async{
    _daoUser.logOut();
  }
}
