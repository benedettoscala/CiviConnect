import 'dart:io';

import 'package:civiconnect/model/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A Data Access Object (DAO) for managing user authentication and role determination.
///
/// This class provides methods for:
/// - Authenticating users using Firebase Authentication.
/// - Determining user roles via Firestore queries.
/// - Managing user data and performing CRUD operations in Firestore.
class UserManagementDAO {
  /// Error code for network request failures.
  static const _networkError = 'network-request-failed';

  /// Instance of FirebaseAuth for user authentication.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Instance of FirebaseFirestore for database operations.
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  /// Cached information about the currently authenticated user.
  GenericUser? _user;

  /// Returns the currently authenticated Firebase user, or `null` if no user is logged in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Retrieves the cached user information, or `null` if no user is cached.
  GenericUser? get getUser => _user;

  /// A stream providing updates to the authentication state.
  ///
  /// Emits the current user when a login, logout, or token refresh occurs.
  /// Emits `null` when the user logs out.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Authenticates a user using email and password.
  ///
  /// Parameters:
  /// - [email]: The user's email address.
  /// - [password]: The user's password.
  ///
  /// Returns:
  /// - `true` if authentication is successful.
  /// - `false` if authentication fails.
  ///
  /// Throws:
  /// - [HttpException]: If a network error occurs.
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == _networkError) {
        throw const HttpException(
            'Errore di rete, controlla la connessione o riprova più tardi.');
      }
      return false;
    }
    return true;
  }

  /// Creates a new user with the specified email and password.
  ///
  /// Parameters:
  /// - [email]: The email address for the new account.
  /// - [password]: The password for the new account.
  ///
  /// Throws:
  /// - [FirebaseAuthException]: If account creation fails (e.g., email already in use).
  Future<bool> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required Map<String, dynamic> additionalData,
  }) async {
    try {
      // Crea l'utente con Firebase Authentication.
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      await UserManagementDAO()
          ._firebaseFirestore
          .collection('citizen')
          .doc(uid)
          .set({...additionalData});
    } catch (e) {
      throw Exception('Email gia in uso');
    }
    return true;
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
    } catch (_) {}

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
    } catch (_) {}

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
          cap: citizenDoc['cap'],
        );
        return _user!;
      }
    } catch (_) {}

    return null;
  }

  /// Retrieves the currently authenticated user's data from Firestore.
  ///
  /// Returns:
  /// - A `Future<Map<String, dynamic>>` containing the user's data.
  ///
  /// Throws:
  /// - [Exception]: If no user is currently authenticated.
  Future<Map<String, dynamic>> getUserData() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
          await _firebaseFirestore.collection('citizen').doc(user.uid).get();
      return snapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception('No authenticated user found.');
    }
  }

  /// Retrieves the municipality data for the currently authenticated user.
  ///
  /// Returns:
  /// - A `Future<Map<String, String>>` containing the municipality data.
  ///
  /// Throws:
  /// - [Exception]: If no user is currently authenticated.
  Future<Map<String, String>> getMunicipalityData() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await _firebaseFirestore
          .collection('municipality')
          .doc(user.uid)
          .get();

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      String email = data.containsKey('email') ? data['email'] : '';
      String municipalityName = data.containsKey('municipalityName')
          ? capitalize(data['municipalityName'])
          : '';
      String province = data.containsKey('province') ? data['province'] : '';

      return {
        'email': email,
        'municipalityName': municipalityName,
        'province': province,
      };
    } else {
      throw Exception('No authenticated user found.');
    }
  }

  /// Capitalizes the first letter of a string and converts the rest to lowercase.
  ///
  /// Parameters:
  /// - [s]: The string to capitalize.
  ///
  /// Returns:
  /// - The capitalized string.
  String capitalize(String s) =>
      s[0].toUpperCase() + s.substring(1).toLowerCase();

  /// Updates the authenticated user's data in Firestore.
  ///
  /// Parameters:
  /// - [userData]: A map containing the data to update.
  Future<void> updateUserData(Map<String, dynamic> userData) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firebaseFirestore
          .collection('citizen')
          .doc(user.uid)
          .update(userData);
    } else {
      throw Exception('No authenticated user found.');
    }
  }

  // -------------------- User Data Modification Methods --------------------

  /// Updates the email address of the authenticated user.
  ///
  /// Parameters:
  /// - [newEmail]: The new email to set.
  /// - [currentPassword]: The user's current password (required for re-authentication).
  /// Updates the email address of the authenticated user.
  ///
  /// Parameters:
  /// - [newEmail]: The new email to set.
  /// - [currentPassword]: The user's current password (required for re-authentication).
  /// Updates the email address of the authenticated user.
  ///
  /// Parameters:
  /// - [newEmail]: The new email to set.
  /// - [currentPassword]: The user's current password (required for re-authentication).
  Future<void> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    User user = _firebaseAuth.currentUser!;

    AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!, password: currentPassword);

    await user.reauthenticateWithCredential(credential);
    // ignore: deprecated_member_use
    await user.updateEmail(newEmail);
  }

  /// Updates the password of the authenticated user.
  ///
  /// Parameters:
  /// - [currentPassword]: The user's current password (required for re-authentication).
  /// - [newPassword]: The new password to set.
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    User user = _firebaseAuth.currentUser!;

    AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!, password: currentPassword);

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}
