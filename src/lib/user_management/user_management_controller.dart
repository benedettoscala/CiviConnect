import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:flutter/material.dart';

/// Controller class responsible for managing user-related operations.
///
/// This class encapsulates the logic for user login, user creation,
/// and credential validation. It provides methods to interact with the
/// user DAO and handles navigation to other pages.
class UserManagementController {
  /// Redirect page to navigate to after successful login.
  final Widget redirectPage;

  /// Constructor for the `UserManagementController` class.
  ///
  /// This constructor require a `redirectPage` parameter, which is the page.
  UserManagementController({required this.redirectPage});

  /// Method to handle user login.
  /// This will be redirect route after successful login.
  ///
  /// Parameters:
  /// - [context]: The current context of the Flutter application.
  /// - [email]: The user's email address.
  /// - [password]: The user's password.
  Future<bool> login(BuildContext context,
      {required String email, required String password}) {
    return _validateAuth(context, email, password);
  }

  /// Method to validate user credentials and complete authentication.
  ///
  /// This method uses the `UserManagementDAO` to create a user with the provided
  /// email and password, then navigates to the [redirectPage].
  ///
  /// Parameters:
  /// - [context]: The current context of the Flutter application.
  Future<bool> _validateAuth(BuildContext context, email, password) async {

    final bool result = await UserManagementDAO().signInWithEmailAndPassword(
        email: email, password: password);

    if (result) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => redirectPage),
          (route) => false);
    }

    return result;
  }

  Future<Map<String, dynamic>> getUserData() async {
    try {
      return await UserManagementDAO().getUserData();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateUserData(Map<String, dynamic> userData) async {
    try {
      await UserManagementDAO().updateUserData(userData);
    } catch (e) {
      throw e;
    }
  }

  // -------------------- Methods for Modify User Data --------------------

  /// Method to change the user's email.
  ///
  /// Uses the DAO to update the email and handles any exceptions.
  ///
  /// Parameters:
  /// - [context]: The current context of the Flutter application.
  /// - [newEmail]: The new email to set.
  /// - [currentPassword]: The user's current password.
  Future<void> changeEmail(BuildContext context,
      {required String newEmail, required String currentPassword}) async {
    try {
      await UserManagementDAO().updateEmail(
          newEmail: newEmail, currentPassword: currentPassword);
    } catch (e) {
      throw e;
    }
  }

  /// Method to change the user's password.
  ///
  /// Uses the DAO to update the password and handles any exceptions.
  ///
  /// Parameters:
  /// - [context]: The current context of the Flutter application.
  /// - [currentPassword]: The user's current password.
  /// - [newPassword]: The new password to set.
  Future<void> changePassword(BuildContext context,
      {required String currentPassword, required String newPassword}) async {
    await UserManagementDAO().updatePassword(
        currentPassword: currentPassword, newPassword: newPassword);
  }
}
