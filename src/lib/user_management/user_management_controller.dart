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
    {required String email, required String password, required String username, required String name, required String surname, required Map<String, String> address, required String city, required String cap}) {
  user = UserWrapper.fromRegistration(
    email: email,
    password: password,
    username: username,
    name: name,
    surname: surname,
    address: address,
    city: city,
    cap: cap,
  );

  return _validateRegistration(context);
  }

  Future<bool> _validateRegistration(BuildContext context) async {
    UserManagementDAO userDao = UserManagementDAO();
    final bool result= await userDao.createUserWithEmailAndPassword(
          email: user.email,
          password: user.password!,
          additionalData: {
            'firstName': user.name,
            'lastName': user.surname,
            'address': user.address,
            'city': user.city,
            'cap': user.cap
          });


    if (result) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => redirectPage),
      );
    }

    return result;
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

  //MI MANCA MARTINA :(
}
