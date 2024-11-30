import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A Data Access Object (DAO) for managing user authentication
/// using Firebase Authentication.
class UserManagementDAO {
  // Private instance of FirebaseAuth used to interact with authentication services.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Private instance of FirebaseFirestore used to interact with Firestore.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns the currently authenticated user, or `null` if no user is logged in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// A stream that provides updates to the authentication state.
  ///
  /// Emits the current user whenever there is a change, such as a login, logout,
  /// or token refresh. Emits `null` if the user logs out.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Signs in a user with the provided email and password.
  ///
  /// Throws no exceptions. Returns `true` if the sign-in succeeds,
  /// or `false` if an error occurs.
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
  /// Throws an exception if the account creation fails.
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  /// Logs out the currently authenticated user.
  ///
  /// Throws an exception if the logout operation fails.
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  // -------------------- Methods for Modify User Data --------------------

  /// Updates the email of the authenticated user.
  ///
  /// Requires the user to re-authenticate with the current password
  /// for security reasons.
  ///
  /// Parameters:
  /// - [newEmail]: The new email to set.
  /// - [currentPassword]: The user's current password.
  Future<void> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    User user = _firebaseAuth.currentUser!;

    // Create credentials with the user's email and current password.
    AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!, password: currentPassword);

    // Re-authenticate the user.
    await user.reauthenticateWithCredential(credential);

    // Update the user's email.
    await user.updateEmail(newEmail);

    // Update the email in Firestore.
    await _firestore.collection('citizen').doc(user.uid).update({'email': newEmail});
  }

  /// Updates the password of the authenticated user.
  ///
  /// Requires the user to re-authenticate with the current password
  /// for security reasons.
  ///
  /// Parameters:
  /// - [currentPassword]: The user's current password.
  /// - [newPassword]: The new password to set.
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    User user = _firebaseAuth.currentUser!;

    // Create credentials with the user's email and current password.
    AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!, password: currentPassword);

    // Re-authenticate the user.
    await user.reauthenticateWithCredential(credential);

    // Update the user's password.
    await user.updatePassword(newPassword);
  }

  /// Retrieves the user's data from Firestore.
  Future<Map<String, dynamic>> getUserData() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
      await _firestore.collection('citizen').doc(user.uid).get();
      return snapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception('Nessun utente autenticato');
    }
  }

  /// Updates the user's data in Firestore.
  ///
  /// Parameters:
  /// - [userData]: The user data to update.
  Future<void> updateUserData(Map<String, dynamic> userData) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore.collection('citizen').doc(user.uid).update(userData);
    } else {
      throw Exception('Nessun utente autenticato');
    }
  }
}