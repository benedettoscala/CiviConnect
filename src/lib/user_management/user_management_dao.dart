import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
//import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A Data Access Object (DAO) for managing user authentication
/// using Firebase Authentication.
class UserManagementDAO {
  // Private instance of FirebaseAuth used to interact with authentication services.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

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
  /// Throws an exception if the account creation fails. Ensure to handle
  /// errors such as email already in use or invalid password format.
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
  Future<bool> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required Map<String, dynamic>
        additionalData, // Data aggiuntivi dell'utente.
  }) async {
    try {
      // Crea l'utente con Firebase Authentication.
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Ottieni l'UID dell'utente appena creato.
      String uid = userCredential.user!.uid;

      // Salva i dati aggiuntivi su Firestore.
      await db.collection('citizen').doc(uid).set({...additionalData});
    } catch (e) {
      // Rilancia l'eccezione per una gestione a livello superiore.
      throw Exception('Error creating user: $e');
    }
    return true;
  }

  /// Logs out the currently authenticated user.
  ///
  /// Throws an exception if the logout operation fails. After a successful
  /// logout, `authStateChanges` will emit `null`.
  ///
  /// Example:
  /// ```dart
  /// await userManagementDAO.logOut();
  /// print("User logged out successfully");
  /// ```
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }
}
