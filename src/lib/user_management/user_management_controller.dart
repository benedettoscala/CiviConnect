import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:civiconnect/user_management/user_wrapper.dart';
import 'package:flutter/material.dart';

import '../testing_page.dart';

/// Controller class responsible for managing user-related operations.
///
/// This class encapsulates the logic for user login, user creation,
/// and credential validation. It provides methods to interact with the 
/// user DAO and handles navigation to other pages.
class UserManagementController {
  /// Instance of the user wrapper, containing user-specific information
  /// such as email and password.
  late final UserWrapper user;

  /// Constructor for the `UserManagementController` class.
  ///
  /// This constructor does not require any parameters at initialization.
  UserManagementController();

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
  void login(BuildContext context, {required String email, required String password}) {
    user = UserWrapper.fromLogin(email: email, password: password);

    validateAuth(context);
  }

  /// Method to validate user credentials and complete authentication.
  ///
  /// This method uses the `UserManagementDAO` to create a user with the provided
  /// email and password, then navigates to the `TestingPage`.
  ///
  /// Parameters:
  /// - [context]: The current context of the Flutter application.
  void validateAuth(BuildContext context) {
    UserManagementDAO userDao = UserManagementDAO();

    userDao.createUserWithEmailAndPassword(email: user.email, password: user.password!);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TestingPage(user: user)),
    );
  }
}
