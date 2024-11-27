import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/foundation.dart';

/// An enumeration of user types.
///
/// This is used to define and manage different roles within the application.
enum UserType implements Comparable<UserType> {
  /// Super Administrator (highest privileges).
  admin(value: 0, name: 'Super Administrator'),

  /// Municipality Administrator.
  municipality(value: 1, name: 'Municipality Administrator'),

  /// Regular user (citizen).
  citizen(value: 2, name: 'Regular user'),

  /// Unidentified or unauthorized user.
  unknown(value: -1, name: 'Unknown');

  /// Constructs a `UserType` with the given [value] and [name].
  const UserType({required this.value, required this.name});

  /// The integer value associated with this enum.
  final int value;

  /// The display name of this user type.
  final String name;

  @override
  int compareTo(UserType other) {
    return value - other.value;
  }
}

/// A Data Access Object (DAO) for managing user authentication
/// and role determination using Firebase Authentication and Firestore.
class UserManagementDAO {
  /// Instance of FirebaseAuth used for user authentication.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Instance of FirebaseFirestore used for database operations.
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  /// The user type of the currently authenticated user.
  /// This variable is used as cache.
  late final UserType? _userType;

  /// Returns the currently authenticated user, or `null` if no user is logged in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// A stream providing updates to the authentication state.
  ///
  /// Emits the current user whenever there is a login, logout,
  /// or token refresh. Emits `null` if the user logs out.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Returns the user type of the currently authenticated user.
  UserType get getUserType => _userType!;

  /// Signs in a user using email and password.
  ///
  /// This method attempts to authenticate a user with the given credentials.
  /// Returns `true` if authentication succeeds, or `false` otherwise.
  ///
  /// - [email]: The user's email address.
  /// - [password]: The user's password.
  /// - Returns: `true` if login is successful, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// bool isLoggedIn = await userManagementDAO.signInWithEmailAndPassword(
  ///   email: "user@example.com",
  ///   password: "securePassword123",
  /// );
  /// ```
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      return false;
    }
    return true;
  }

  /// Creates a new user with the provided email and password.
  ///
  /// This method registers a new user in Firebase Authentication.
  /// Throws an exception if account creation fails (e.g., email already in use).
  ///
  /// - [email]: The email address for the new account.
  /// - [password]: The password for the new account.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await userManagementDAO.createUserWithEmailAndPassword(
  ///     email: "newuser@example.com",
  ///     password: "securePassword123",
  ///   );
  ///   print("User created successfully");
  /// } catch (e) {
  ///   print("Error creating user: $e");
  /// }
  /// ```
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  /// Logs out the currently authenticated user.
  ///
  /// This method ends the current user session. After a successful logout,
  /// the `authStateChanges` stream will emit `null`.
  ///
  /// Throws an exception if the logout operation fails.
  ///
  /// Example:
  /// ```dart
  /// await userManagementDAO.logOut();
  /// print("User logged out successfully");
  /// ```
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  /// Determines the user type based on Firestore records.
  ///
  /// This method evaluates the current user's UID against Firestore records
  /// to classify the user as `admin`, `municipality`, `citizen`, or `unknown`.
  ///
  /// - Returns: A `UserType` enum representing the user's role.
  /// - This method caches the user type for future calls.
  ///
  /// Example:
  /// ```dart
  /// UserType userType = await userManagementDAO.determineUserType();
  /// print("User type: ${userType.name}");
  /// ```
  Future<UserType> determineUserType() async {
    User? currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      return UserType.unknown;
    }

    if (_userType != null) {
      return _userType;
    }

    String uid = currentUser.uid;

    try {
      DocumentSnapshot adminDoc =
          await _firebaseFirestore.doc('/private/admin').get();
      if (adminDoc.exists) {
        List<dynamic> adminUIDs = adminDoc['uids'] as List<dynamic>;
        if (adminUIDs.contains(uid)) {
          _userType = UserType.admin;
          return _userType!;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Maybe municipality user?');
      }
    }

    try {
      DocumentSnapshot municipalityDoc =
          await _firebaseFirestore.doc('/municipality/$uid').get();
      if (municipalityDoc.exists) {
        _userType = UserType.municipality;
        return _userType!;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Maybe citizen user?');
      }
    }

    try {
      DocumentSnapshot citizenDoc =
          await _firebaseFirestore.doc('/citizen/$uid').get();
      if (citizenDoc.exists) {
        _userType = UserType.citizen;
        return _userType!;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unknown user');
      }
    }

    return _userType!;
  }
}
