import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      print('Comune già presente nel database: $e');
      return false;
    }
  }

  /// Save credentials for the municipality in the database.
  /// The method saves the municipality's email, password, and province to Firestore.
  /// It also creates a user with Firebase Authentication.
  /// The method also logs in as the admin and logs out after saving the credentials.
  /// The method throws an exception if an error occurs during the process.
  /// Parameters:
  /// - [email]: The email address of the municipality.
  /// - [passwordComune]: The password for the municipality.
  /// - [selectedComune]: A map containing the selected municipality's name and province.
  /// - [passwordAdmin]: The password for the admin user.
  /// Throws:
  /// - An exception if an error occurs during the process.
  /// - An exception if the user type is not an admin.
  /// - An exception if the credentials cannot
  ///  be saved to the database.
  Future<void> saveCredentialsToDatabase(String email, String passwordComune,
      Map<String, String> selectedComune, String passwordAdmin) async {
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
              email: email, password: passwordComune);

      // Logged as municipality and need to log out
      await _firebaseAuth.signOut();

      // Log in as admin
      await _firebaseAuth.signInWithEmailAndPassword(
          email: adminEmail, password: passwordAdmin);

      // Logged as admin
      // Save the municipality data to Firestore.
      await _firebaseFirestore
          .collection('municipality')
          .doc(userCredential.user!.uid)
          .set({
        'municipalityName': selectedComune['Comune'],
        'email': email,
        'province': selectedComune['Provincia'],
      });
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