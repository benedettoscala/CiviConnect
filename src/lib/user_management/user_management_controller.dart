import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:flutter/material.dart';

/// A controller class responsible for managing user-related operations.
///
/// This class encapsulates the logic for user login, user creation,
/// credential validation, and user data modification. It interacts
/// with the `UserManagementDAO` for backend operations and handles
/// navigation within the application.
class UserManagementController {
  /// The page to navigate to after a successful login.
  final Widget redirectPage;

  /// Constructs a `UserManagementController` instance.
  ///
  /// Parameters:
  /// - [redirectPage]: The target page to navigate to after a successful login.
  UserManagementController({required this.redirectPage});

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
        MaterialPageRoute(builder: (context) => redirectPage),
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
}
