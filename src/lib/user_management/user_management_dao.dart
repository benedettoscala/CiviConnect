import 'package:civiconnect/model/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/foundation.dart';

/// A Data Access Object (DAO) for managing user authentication
/// and role determination using Firebase Authentication and Firestore.
class UserManagementDAO {
  /// Instance of FirebaseAuth used for user authentication.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Instance of FirebaseFirestore used for database operations.
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  /// The currently authenticated user information.
  GenericUser? _user;

  /// Returns the currently authenticated user, or `null` if no user is logged in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Get all information about the currently authenticated user.
  GenericUser? get getUser => _user;

  /// A stream providing updates to the authentication state.
  ///
  /// Emits the current user whenever there is a login, logout,
  /// or token refresh. Emits `null` if the user logs out.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

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

  /// Determines the user type by evaluating the current user's UID against Firestore records.
  ///
  /// This method retrieves the Firebase-authenticated user's UID and queries Firestore
  /// to classify the user as one of the following types:
  /// - `Admin`: If the user's UID is listed in the `/private/admin` document.
  /// - `Municipality`: If there is a matching document for the user's UID in the `/municipality` collection.
  /// - `Citizen`: If there is a matching document for the user's UID in the `/citizen` collection.
  /// - `Unknown`: If the user does not match any of the above roles.
  ///
  /// **Caching**:
  /// The user type is cached in memory (`_user`) for subsequent calls to optimize performance.
  ///
  /// **Firestore Structure**:
  /// - Admins: The `/private/admin` document contains a `uids` field, which is a list of admin UIDs.
  /// - Municipalities: Each municipality has a document in the `/municipality` collection, keyed by UID.
  ///   The document contains fields such as:
  ///     - `municipalityName`
  ///     - `province`
  /// - Citizens: Each citizen has a document in the `/citizen` collection, keyed by UID.
  ///   The document contains fields such as:
  ///     - `firstName`
  ///     - `lastName`
  ///     - `city`
  ///     - `address` (a map with `street` and `number`)
  ///     - `CAP`
  ///
  /// **Returns**:
  /// A `Future<GenericUser?>` that resolves to an instance of one of the user types (`Admin`, `Municipality`, or `Citizen`),
  /// or `null` if the user does not exist or their type cannot be determined.
  ///
  /// **Example**:
  /// ```dart
  /// GenericUser? user = await userManagementDAO.determineUserType();
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
  ///
  /// **Error Handling**:
  /// - If Firestore queries fail (e.g., due to network issues or missing documents), the method logs the error
  ///   in debug mode and proceeds to check other user types.
  ///
  /// **Implementation**:
  /// The method follows these steps:
  /// 1. Checks if the current user is authenticated. If not, returns `null`.
  /// 2. Checks the cached user type (`_user`) to avoid redundant Firestore queries.
  /// 3. Queries Firestore in the following order:
  ///    - Admin (`/private/admin`)
  ///    - Municipality (`/municipality/{uid}`)
  ///    - Citizen (`/citizen/{uid}`)
  /// 4. Returns the user type if a match is found; otherwise, returns `null`.
  ///
  Future<GenericUser?> determineUserType() async {
    User? currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      return null;
    }

    if (_user != null) {
      return _user;
    }

    String uid = currentUser.uid;

    try {
      DocumentSnapshot adminDoc =
      await _firebaseFirestore.doc('/private/admin').get();
      if (adminDoc.exists) {
        List<dynamic> adminUIDs = adminDoc['uids'] as List<dynamic>;
        if (adminUIDs.contains(uid)) {
          _user = Admin(user: currentUser);
          return _user!;
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
        _user = Municipality(
          user: currentUser,
          municipalityName: municipalityDoc['municipalityName'],
          province: municipalityDoc['province'],
        );
        return _user!;
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
        _user = Citizen(
          user: currentUser,
          firstName: citizenDoc['firstName'],
          lastName: citizenDoc['lastName'],
          city: citizenDoc['city'],
          address: {
            'street': citizenDoc['address']['street'],
            'number': citizenDoc['address']['number'],
          },
          cap: citizenDoc['CAP'],
        );
        return _user!;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unknown user');
      }
    }

    return null;
  }
}
