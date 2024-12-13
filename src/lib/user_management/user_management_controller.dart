import 'dart:convert';

import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/users_model.dart';

/// A controller class responsible for managing user-related operations.
///
/// This class encapsulates the logic for user login, user creation,
/// credential validation, and user data modification. It interacts
/// with the `UserManagementDAO` for backend operations and handles
/// navigation within the application.
class UserManagementController {
  /// The page to navigate to after a successful login.
  final Widget? redirectPage;

  /// Constructs a `UserManagementController` instance.
  ///
  /// Parameters:
  /// - [redirectPage]: The target page to navigate to after a successful login.
  UserManagementController({this.redirectPage});

  /// Handles user login.
  ///
  /// This method validates the user's credentials and, upon success,
  /// navigates to the `redirectPage`.
  ///
  /// Parameters:
  /// - [context]: The current BuildContext of the application.
  /// - [email]: The user's email address.
  /// - [password]: The user's password.
  ///
  /// Returns:
  /// - A `Future<bool>` indicating whether the login was successful.
  Future<bool> login(BuildContext context,
      {required String email, required String password}) {
    return _validateAuth(context, email, password);
  }

  /// Validates user credentials and completes the authentication process.
  ///
  /// Upon successful validation, navigates to the [redirectPage].
  ///
  /// Parameters:
  /// - [context]: The current BuildContext of the application.
  /// - [email]: The user's email address.
  /// - [password]: The user's password.
  ///
  /// Returns:
  /// - A `Future<bool>` indicating whether the authentication was successful.
  Future<bool> _validateAuth(BuildContext context, email, password) async {
    final bool result = await UserManagementDAO()
        .signInWithEmailAndPassword(email: email, password: password);

    if (result) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => redirectPage!),
        (route) => false,
      );
    }

    return result;
  }

  /// Fetches the current user's data.
  ///
  /// Returns:
  /// - A `Future<Map<String, dynamic>>` containing the user's data.
  Future<Map<String, dynamic>> getUserData() async {
    return await UserManagementDAO().getUserData();
  }

  /// Fetches the municipality data.
  ///
  /// Returns:
  /// - A `Future<Map<String, String>>` containing the municipality data.
  Future<Map<String, String>> getMunicipalityData() async {
    return await UserManagementDAO().getMunicipalityData();
  }

  /// Updates the user's data.
  ///
  /// Parameters:
  /// - [userData]: A map containing the user's updated data.
  Future<void> updateUserData(Map<String, dynamic> userData) async {
    await UserManagementDAO().updateUserData(userData);
  }

  // -------------------- User Data Modification Methods --------------------

  /// Changes the user's email address.
  ///
  /// This method updates the email via the DAO and handles any exceptions.
  ///
  /// Parameters:
  /// - [context]: The current BuildContext of the application.
  /// - [newEmail]: The new email address to set.
  /// - [currentPassword]: The user's current password for authentication.
  Future<void> changeEmail(BuildContext context,
      {required String newEmail, required String currentPassword}) async {
    await UserManagementDAO()
        .updateEmail(newEmail: newEmail, currentPassword: currentPassword);
  }

  /// Changes the user's password.
  ///
  /// This method updates the password via the DAO and handles any exceptions.
  ///
  /// Parameters:
  /// - [context]: The current BuildContext of the application.
  /// - [currentPassword]: The user's current password for authentication.
  /// - [newPassword]: The new password to set.
  Future<void> changePassword(BuildContext context,
      {required String currentPassword, required String newPassword}) async {
    await UserManagementDAO().updatePassword(
        currentPassword: currentPassword, newPassword: newPassword);
  }

  /// Method to handle user registration.
  ///
  /// This method initializes a `UserWrapper` instance using the provided email,
  /// password, username, name, surname, address, city, and cap, then calls the
  /// `_validateAuth` method to complete the authentication process.
  ///
  /// Parameters:
  /// - [context]: The current context of the Flutter application.
  /// - [email]: The user's email address.
  /// - [password]: The user's password.
  /// - [username]: The user's username.
  /// - [name]: The user's name.
  /// - [surname]: The user's surname.
  /// - [address]: The user's address.
  /// - [city]: The user's city.
  /// - [cap]: The user's CAP.
  ///
  /// Returns:
  /// - A `Future<bool>` that resolves to `true` if the registration is successful.
  ///   Otherwise, it resolves to `false`.
  ///
  /// Example:
  /// ```dart
  /// bool isRegistered = await controller.register(
  ///   context,
  ///   email: 'example@example.com',
  ///   password: 'securePassword',
  ///   username: 'username123',
  ///   name: 'John',
  ///   surname: 'Doe',
  ///   address: '123 Main St',
  ///   city: 'Metropolis',
  ///   cap: '12345',
  /// );
  /// ```
  Future<bool> register(BuildContext context,
      {required String email,
      required String password,
      required String name,
      required String surname,
      required Map<String, String> address,
      required String city,
      required String cap}) {
    // Citizen user = Citizen(
    //       firstName: name,
    //       lastName: surname,
    //       address: address,
    //       city: city,
    //       cap: cap,
    //     );
    // we can't create a Citizen object because no user is logged in.

    return _validateRegistration(
        context, email, password, name, surname, address, city, cap);
  }

  Future<bool> _validateRegistration(BuildContext context, email, password,
      name, surname, address, city, cap) async {
    UserManagementDAO userDao = UserManagementDAO();
    final bool result = await userDao.createUserWithEmailAndPassword(
        email: email,
        password: password!,
        additionalData: {
          'firstName': name,
          'lastName': surname,
          'address': address,
          'city': city,
          'cap': cap
        });

    if (result) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => redirectPage!),
        (route) => false,
      );
    }

    return result;
  }

  /// Checks if the current user is an administrator.
  Future<bool> checkIfUserIsAdmin() async {
    return await UserManagementDAO().determineUserType() is Admin;
  }

  /// By Marco: MI MANCA MARTINA :(
  /// Marco is sad
  /// Please help Marco find Martina
  String marcoMissingMartina() {
    return 'Marco is sad';
  }

  /// Logout the current user.
  /// The method logs out the current user.
  /// Throws an exception if an error occurs during the process.
  /// Returns:
  /// - A `Future<void>` indicating the completion of the operation.
  /// Throws:
  /// - An exception if an error occurs during the process.
  Future<void> logOut() async {
    try {
      await UserManagementDAO().logOut();
    } catch (e) {
      throw Exception('Errore durante il logout');
    }
  }

  /// Determines the type of the current user.
  /// The GenericUser type is a super class of all the user types.
  ///
  /// Returns:
  /// - A `Future<GenericUser?>` containing the type of the current user.
  ///
  /// Example:
  /// ```dart
  /// GenericUser? user = await UserManagementController().determineUserType();
  /// if (user is Admin) {
  ///   print("User is an Admin");
  /// } else if (user is Municipality) {
  ///   print("User is a Municipality");
  /// } else if (user is Citizen) {
  ///   print("User is a Citizen");
  /// } else {
  ///   print("User type could not be determined");
  /// }
  /// ```
  Future<GenericUser?> determineUserType() async {
    return await UserManagementDAO().determineUserType();
  }

  /// Verifica se il CAP fornito corrisponde alla città utilizzando un file JSON locale.
  ///
  /// Questo metodo legge un file JSON locale contenente una lista di CAP e città,
  /// e controlla se il CAP specificato corrisponde alla città data. Restituisce `true`
  /// se il CAP corrisponde alla città, altrimenti `false`.
  ///
  /// Parametri:
  /// - [cap]: Il codice postale da verificare.
  /// - [city]: Il nome della città da verificare rispetto al CAP.
  ///
  /// Ritorna:
  /// - Un `Future<bool>` che risolve a `true` se il CAP corrisponde alla città,
  ///   altrimenti `false`.
  ///
  /// Esempio:
  /// ```dart
  /// bool isMatching = await isCapMatchingCityAPI('00100', 'Rome');
  /// if (isMatching) {
  ///   print('Il CAP corrisponde alla città.');
  /// } else {
  ///   print('Il CAP non corrisponde alla città.');
  /// }
  /// ```
  Future<bool> isCapMatchingCityAPI(String cap, String city) async {
    try {
      // Legge il contenuto del file JSON dalla directory "files"
      final jsonData = await rootBundle
          .loadString('assets/files/comuni-localita-cap-italia.json');

      // Decodifica il contenuto del file in una lista di mappe
      final List<dynamic> comuniData =
      json.decode(jsonData)['Sheet 1 - comuni-localita-cap-i'];

      // Cerca se c'è un elemento con il CAP e il Comune corrispondente
      final match = comuniData.any((element) =>
      element['CAP'] == cap &&
          element['Comune Localita’'].toLowerCase() == city.toLowerCase());

      return match; // Restituisce true se corrisponde, altrimenti false
    } catch (e) {
      // In caso di errore (es. file non trovato), stampa il problema e restituisce false
      //print('Errore nel controllo CAP-Città: $e');
      return false;
    }
  }
}
