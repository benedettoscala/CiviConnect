import 'dart:convert';
import 'dart:math';

import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:flutter/services.dart';
import 'package:string_similarity/string_similarity.dart';

import 'gestione_admin_dao.dart';

/// A controller class responsible for managing Admin-related operations.
///
/// This class encapsulates the logic for generating credentials for municipalities.
/// It interacts with the `AdminManagementDAO` for backend operations.
///
/// The controller provides methods for:
/// - Loading the list of municipalities from a JSON file.
/// - Filtering the list of municipalities based on a query.
/// - Checking if a municipality exists in the database.
/// - Generating credentials for municipalities.
/// - Generating a random password for the municipality.
/// - Logging out the current user.
class AdminManagementController {
  //-------- Generate Credentials for Municipality --------

  final AdminManagementDAO _daoAdmin = AdminManagementDAO();
  final UserManagementDAO _daoUser = UserManagementDAO();

  /// Load the list of municipalities from JSON.
  /// The JSON file contains a list of municipalities with their provinces.
  /// The method returns a list of maps containing the municipalities and provinces.
  /// Throws an exception if an error occurs during the process.
  /// Returns:
  /// - A `Future<List<Map<String, String>>>` containing the list of municipalities.
  /// Throws:
  /// - An exception if an error occurs during the process.
  /// - An exception if the JSON file cannot be loaded.
  Future<List<Map<String, String>>> loadMunicipalities() async {
    String data = await rootBundle
        .loadString('assets/files/comuni-localita-cap-italia.json');
    Map<String, dynamic> jsonResult = json.decode(data);

    //print('JSON Result: $jsonResult'); // Debug

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

  /// Filter the list of municipalities based on the query.
  /// The query is used to search for municipalities by name.
  /// The search is case-insensitive and uses a similarity score.
  /// The top 7 most similar municipalities are shown first.
  /// The remaining municipalities are shown in alphabetical order.
  /// Returns a list of filtered municipalities.
  /// Parameters:
  /// - [allMunicipalities]: The list of all municipalities.
  /// - [query]: The search query to filter the municipalities.
  /// Returns:
  /// - A list of filtered municipalities.
  /// Throws:
  /// - An exception if an error occurs during the process.
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

  /// Checks if the municipality exists in the database.
  /// The municipality name is used to check if it exists in the database.
  /// Returns a boolean indicating whether the municipality exists in the database.
  /// Parameters:
  /// - [comune]: The name of the municipality to check.
  /// Returns:
  /// - A `Future<bool>` indicating whether the municipality exists in the database.
  /// Throws:
  /// - An exception if an error occurs during the process.
  Future<bool> municipalityExistsInDatabase(String comune) async {
    return await _daoAdmin.municipalityExistsInDatabase(comune);
  }

  /// Generate credentials for the municipality.
  /// The method generates credentials for the municipality and sends them via email.
  /// The method creates a new user in Firebase Authentication and saves the municipality data to Firestore.
  /// Parameters:
  /// - [selectedMunicipality]: The selected municipality data.
  /// - [adminPassword]: The password for the admin user.
  /// - [emailComune]: The email address for the municipality.
  /// Throws an exception if an error occurs during the process.
  /// Throws:
  /// - An exception if an error occurs during the process.
  /// - An exception if the admin password is incorrect.
  /// - An exception if the authenticated user is not found.
  /// - An exception if the municipality data cannot be saved to Firestore.
  Future<void> generateCredentials(Map<String, String> selectedMunicipality,
      String adminPassword, String emailComune) async {
    String municipalityEmailPart =
        selectedMunicipality['Comune']!.toLowerCase().replaceAll(' ', '');
    String emailGen = 'comune.$municipalityEmailPart@anci.gov';
    String passwordGen = generatePassword();

    if (validateEmail(emailGen) != null ||
        validatePassword(passwordGen) != null) {
      throw ('Errore nella generazione delle credenziali');
    }

    // Save municipality credentials to database
    await _daoAdmin.createAccountAndSendCredentials(emailGen, passwordGen,
        emailComune, selectedMunicipality, adminPassword);
  }

  /// Generate a random password for the municipality.
  /// The password is 15 characters long and contains uppercase, lowercase, numbers, and special characters.
  /// The password is shuffled for added security.
  /// Returns the generated password.
  /// Throws an exception if an error occurs during the process.
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

  /// Validate the password.
  /// The password must contain at least 8 characters.
  /// The password must contain at most 255 characters.
  /// The password must contain only letters, numbers, and special characters.
  /// The password must contain at least one uppercase letter.
  /// The password must contain at least one lowercase letter.
  /// The password must contain at least one number.
  /// The password must contain at least one special character.
  /// Returns an error message if the password is invalid.
  /// Parameters:
  /// - [password]: The password to validate.
  /// Returns:
  /// - An error message if the password is invalid.
  /// - An empty string if the password is valid.
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

  /// Validate the email address.
  /// The email address must be in a valid format.
  /// Returns an error message if the email is invalid.
  /// Parameters:
  /// - [email]: The email address to validate.
  /// Returns:
  /// - An error message if the email is invalid.
  /// - An empty string if the email is valid.
  /// Throws:
  /// - An exception if an error occurs during the process.
  String? validateEmail(String email) {
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Inserisci un indirizzo email valido';
    }
    return null;
  }

  /// Validate the admin password.
  /// The admin password is used to authenticate the operation.
  /// Returns a boolean indicating whether the password is correct.
  /// Parameters:
  /// - [password]: The admin password to validate.
  /// Returns:
  /// - A `Future<bool>` indicating whether the password is correct.
  /// Throws:
  /// - An exception if an error occurs during the process.
  /// - An exception if the password is incorrect.
  Future<bool> validateAdminPassword(String password) {
    return _daoAdmin.validateAdminPassword(password);
  }

  /// Logout the current Admin.
  /// The method logs out the current Admin user.
  /// Throws an exception if an error occurs during the process.
  /// Returns:
  /// - A `Future<void>` indicating the completion of the operation.
  /// Throws:
  /// - An exception if an error occurs during the process.
  Future<void> logOut() async {
    _daoUser.logOut();
  }
}
