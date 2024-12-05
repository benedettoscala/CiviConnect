import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


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
  Future<void> saveCredentialsToDatabase(
      String email, String password, Map<String, String> selectedComune) async {
    try {
      // Create the user with Firebase Authentication.
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

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
      // TODO: Remove user if creation fails
      print('Errore nel salvataggio delle credenziali: $e');
      throw Exception('Errore nel salvataggio delle credenziali: $e');
    }
  }
}
