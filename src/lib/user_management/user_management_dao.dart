import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

/// A Data Access Object (DAO) for managing user authentication
/// using Firebase Authentication.
class UserManagementDAO {
  // Private instance of FirebaseAuth used to interact with authentication services.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
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
