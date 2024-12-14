import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../model/users_model.dart';

/// A Data Access Object (DAO) for managing user authentication and role determination.
///
/// This class provides methods for:
/// - Checking if a municipality already exists in the database.
/// - Generating credentials for municipalities.
class AdminManagementDAO {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  //-------- Generate Credentials for Municipality --------

  /// Check if the municipality already exists in the database.
  /// The method queries the Firestore database to check if the municipality is already present.
  /// The method returns true if the municipality is found, otherwise false.
  /// Parameters:
  /// - [comune]: The name of the municipality to check.
  /// Returns:
  /// - A `Future<bool>` indicating whether the municipality exists in the database.
  /// Throws:
  /// - An exception if an error occurs during the process.
  Future<bool> municipalityExistsInDatabase(String comune) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection('municipality')
          .where('municipalityName', isEqualTo: comune)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Municipality already exists
      return false;
    }
  }

  /// Generate credentials for the municipality.
  /// The method generates credentials for the municipality and sends them via email.
  /// The method creates a new user in Firebase Authentication and saves the municipality data to Firestore.
  /// Parameters:
  /// - [emailGen]: The email address for the municipality user.
  /// - [passwordGen]: The password for the municipality user.
  /// - [emailComune]: The email address for the municipality.
  /// - [selectedComune]: The selected municipality data.
  /// - [passwordAdmin]: The password for the admin user.
  /// Throws:
  /// - An exception if an error occurs during the process.
  /// - An exception if the admin password is incorrect.
  /// - An exception if the authenticated user is not found.
  /// - An exception if the municipality data cannot be saved to Firestore.
  Future<void> createAccountAndSendCredentials(
      String emailGen,
      String passwordGen,
      String emailComune,
      Map<String, String> selectedComune,
      String passwordAdmin) async {

    UserManagementDAO userManagementDAO = UserManagementDAO();
    GenericUser? genericUser = await userManagementDAO.determineUserType();
    String adminEmail = genericUser?.email?.trim() ?? '';

    // Log in as admin
    await _firebaseAuth.signInWithEmailAndPassword(
        email: adminEmail, password: passwordAdmin);

    if (FirebaseAuth.instance.currentUser == null) {
      throw ('Errore di autenticazione Admin.');
    }

    // Save comune and provincia in variables
    String comune = selectedComune['Comune']!.toLowerCase();
    String provincia = selectedComune['Provincia']!;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.getIdToken(true);
    }

    final callable = FirebaseFunctions.instance.httpsCallable('createAccountAndSendCredentialsv1');
    final result = await callable.call({
      'emailGen': emailGen,
      'passwordGen': passwordGen,
      'emailComune': emailComune,
      'comune': comune,
      'provincia': provincia
    });
  }

  /// Deprecated method to save credentials to the database.
  Future<void> saveCredentialsToDatabase(
      String emailGen,
      String emailComune,
      String passwordGen,
      String passwordAdmin,
      Map<String, String> selectedComune) async {
    UserManagementDAO userManagementDAO = UserManagementDAO();
    GenericUser? genericUser = await userManagementDAO.determineUserType();
    if (genericUser == null || genericUser is! Admin) {
      throw ('Errore nel salvataggio delle credenziali');
    }

    try {
      // Save the Admin email
      String adminEmail = genericUser.email?.trim() ?? '';

      // Check if Admin password is correct
      bool isCorrect = await validateAdminPassword(passwordAdmin);

      if (!isCorrect) {
        throw ('Password Admin non corretta');
      }

      // Create the user with Firebase Authentication.
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: emailGen, password: passwordGen);

      // Logged as municipality and need to log out
      await _firebaseAuth.signOut();

      // Log in as admin
      await _firebaseAuth.signInWithEmailAndPassword(
          email: adminEmail, password: passwordAdmin);

      // Save comune and provincia in variables
      String comune = selectedComune['Comune']!.toLowerCase();
      String provincia = selectedComune['Provincia']!;

      print(emailComune);

      // Logged as admin
      // Save the municipality data to Firestore.
      await _firebaseFirestore
          .collection('municipality')
          .doc(userCredential.user!.uid)
          .set({
        'municipalityName': selectedComune['Comune']!.toLowerCase(),
        'province': selectedComune['Provincia'],
      });

      // Send email to verify the email
      // Workaround to send email verification works only with emailComune alredy verified
      await _firebaseAuth.sendPasswordResetEmail(email: emailComune);
    } catch (e) {
      throw ('Errore nel salvataggio delle credenziali, $e');
    }
  }

  /// Validate the admin password.
  /// The method reauthenticates the admin user with the provided password.
  /// The method returns true if the password is correct, otherwise false.
  /// Parameters:
  /// - [passwordAdmin]: The password for the admin user.
  /// Returns:
  /// - A `Future<bool>` indicating whether the password is correct.
  /// Throws:
  /// - An exception if the authenticated user is not found.
  Future<bool> validateAdminPassword(String passwordAdmin) async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw ('Errore di autenticazione Admin.');
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordAdmin,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }
}
