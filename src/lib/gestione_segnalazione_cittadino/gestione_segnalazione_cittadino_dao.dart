import 'package:civiconnect/model/users_model.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

/// Data Access Object (DAO) for managing citizen reports.
class CitizenReportManagementDAO {
  final UserManagementDAO _userManagementDAO;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  /// Constructs a new `CitizenReportManagementDAO` instance.
  ///
  /// Parameters:
  /// - [userManagementDAO]: An optional instance of `UserManagementDAO`. If not provided, a new instance of `UserManagementDAO` will be created.
  CitizenReportManagementDAO({UserManagementDAO? userManagementDAO}) : _userManagementDAO = userManagementDAO ?? UserManagementDAO();

  /// Retrieves a list of reports for a given city.
  ///
  /// Parameters:
  /// - [city]: The name of the city for which to retrieve the reports.
  ///
  /// Returns:
  /// - A `Future<List<Map<String, dynamic>>?>` containing the list of reports for the specified city, or `null` if the user is not valid.
  ///
  /// Throws:
  /// - [Exception]: If the user is not logged in.
  ///
  /// Preconditions:
  /// - The user must be logged in and either a `Municipality` with the specified city name or a `Citizen`.
  Future<List<Map<String, dynamic>>?> getReportList({required String city, DocumentSnapshot? lastDocument}) async {
      if(! await _checkForUserValidity(city)) {
        return null;
      }
      return await _getTenReportsByOffset(city: city, lastDocument: lastDocument);
  }



  /* --------------------------- PRIVATE METHODS ---------------------------------- */

  /// Retrieves the next ten reports for a given city, starting from the last retrieved report.
  ///
  /// Parameters:
  /// - [city]: The name of the city for which to retrieve the reports.
  ///
  /// Returns:
  /// - A `Future<List<Map<String, dynamic>>>` containing the next ten reports for the specified city.
  ////
/// Throws:
/// - [Exception]: If there is an error retrieving the data.
Future<List<Map<String, dynamic>>?> _getTenReportsByOffset({required String city, DocumentSnapshot? lastDocument}) async {
  Query<Map<String, dynamic>> query = _firestore.collection('reports').doc(city.toLowerCase()).collection('${city.toLowerCase()}_reports')
    .orderBy('title', descending: true).limit(10);

  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument);
  }

  try {
    final querySnapshot = await query.get();
    if (querySnapshot.docs.isEmpty) {
      return null;
    }
    final data = querySnapshot.docs.map((doc) => doc.data()).toList();
    return data;

  } catch (e) {
    throw Exception('Error retrieving data: $e');
  }
}
  /* -------------------------------- UTILITY PRIVATE METHODS ----------------------------- */


  /// Checks if the current user is valid for the given city.
  ///
  /// Parameters:
  /// - [city]: The name of the city to check.
  ///
  /// Returns:
  /// - A `bool` indicating whether the user is valid for the specified city.
  ///
  /// Throws:
  /// - [Exception]: If the user is not logged in.
  Future<bool> _checkForUserValidity(String? city) async {
    GenericUser? user = await _userManagementDAO.determineUserType();
    if (user == null) {
      throw Exception('Utente non loggato!');
    }
    return (user is Municipality && (user).municipalityName == city) || user is Citizen;
  }

}


/// Mock implementation of the `CitizenReportManagementDAO` class.
class MockCitizenReportManagementDAO extends Mock implements CitizenReportManagementDAO {

  @override
  Future<List<Map<String, dynamic>>?> getReportList({required String city, DocumentSnapshot? lastDocument}) async {
    Map<String, dynamic> report = {
      'reportId': '123',
      'uid': '456',
      'title': 'Test Report',
      'description': 'This is a test report',
      'photo': 'test.jpg',
      'address': {
        'street': 'Main St',
        'number': '123',
      },
      'location': const GeoPoint(0.0, 0.0),
      'city': 'Test City',
      'category': 'Illuminazione',
      'status': 'In Lavorazione',
      'authorFirstName': 'John',
      'authorLastName': 'Doe',
    };

    List<Map<String, dynamic>> reports = [];
    for(int i = 0; i < 10; i++) {
      reports.add(report);
    }

    return Future.value(reports);
  }
}