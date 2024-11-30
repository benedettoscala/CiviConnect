import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:civiconnect/user_management/user_wrapper.dart';
import 'package:flutter/material.dart';

/// Controller class responsible for managing user-related operations.
///
/// This class encapsulates the logic for user login, user creation,
/// and credential validation. It provides methods to interact with the
/// user DAO and handles navigation to other pages.
class UserManagementController {
  /// Instance of the user wrapper, containing user-specific information
  /// such as email and password.
  late final UserWrapper user;

  /// Redirect page to navigate to after successful login.
  final Widget redirectPage;

  /// Instance of the user DAO, used to interact with the user database.
  final UserManagementDAO userDao = UserManagementDAO();

  /// Constructor for the `UserManagementController` class.
  ///
  /// This constructor require a `redirectPage` parameter, which is the page.
  UserManagementController({required this.redirectPage});

  /// Method to handle user login.
  ///
  /// This method initializes a `UserWrapper` instance using the provided email
  /// and password, and then calls the `validateAuth` method to complete the
  /// authentication process.
  ///
  /// Parameters:
  /// - [context]: The current context of the Flutter application.
  /// - [email]: The user's email address.
  /// - [password]: The user's password.
  Future<bool> login(BuildContext context,
      {required String email, required String password}) {
    user = UserWrapper.fromLogin(email: email, password: password);

    return _validateAuth(context);
  }

  /// Method to validate user credentials and complete authentication.
  ///
  /// This method uses the `UserManagementDAO` to create a user with the provided
  /// email and password, then navigates to the [redirectPage].
  ///
  /// Parameters:
  /// - [context]: The current context of the Flutter application.
  Future<bool> _validateAuth(BuildContext context) async {
    UserManagementDAO userDao = UserManagementDAO();

    final bool result = await userDao.signInWithEmailAndPassword(
        email: user.email, password: user.password!);

    if (result) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => redirectPage),
      );
    }

    return result;
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
      await userDao.updateEmail(
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
    try {
      await userDao.updatePassword(
          currentPassword: currentPassword, newPassword: newPassword);
    } catch (e) {
      throw e;
    }
  }

  /// Retrieves the user's data.
  Future<Map<String, dynamic>> getUserData() async {
    try {
      return await userDao.getUserData();
    } catch (e) {
      throw e;
    }
  }

  /// Updates the user's data.
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      await userDao.updateUserData(userData);
    } catch (e) {
      throw e;
    }
  }
}