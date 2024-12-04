import 'package:civiconnect/model/users_model.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  /// - A `Future<List<Map<String, dynamic>>>` containing the list of reports for the specified city, or `null` if the user is not valid.
  ///
  /// Throws:
  /// - [Exception]: If the user is not logged in.
  ///
  /// Preconditions:
  /// - The user must be logged in and either a `Municipality` with the specified city name or a `Citizen`.
  Future<List<Map<String, dynamic>>>? getReportList(String city){
      if(!_checkForUserValidity(city)) {
        return null;
      }
      return _getTenReportsByOffset(city: city);
  }



  /* --------------------------- PRIVATE METHODS ---------------------------------- */

  /// Retrieves the next ten reports for a given city, starting from the last retrieved report.
  ///
  /// Parameters:
  /// - [city]: The name of the city for which to retrieve the reports.
  ///
  /// Returns:
  /// - A `Future<List<Map<String, dynamic>>>` containing the next ten reports for the specified city.
  ///
  /// Throws:
  /// - [Exception]: If there is an error retrieving the data.
  Future<List<Map<String, dynamic>>> _getTenReportsByOffset({required String city}) async {
    //final reports = await _firestore.collection(getPath(city, null)).orderBy('creationDate', descending: true).startAt([offset]).limit(10).get();
    final first = _firestore.collection(_getPath(city, null)).orderBy('creationDate', descending: true).limit(10);
    return first.get().then(
          (documentSnapshots) {
        // Get the last visible document
        final lastVisible = documentSnapshots.docs[documentSnapshots.size - 1];

        // Construct a new query starting at this document,
        // get the next 25 cities.
        final next = _firestore
            .collection(_getPath(city, null))
            .orderBy('creationDate', descending: true)
            .startAfterDocument(lastVisible)
            .limit(10);
      },
      onError: (e) => throw Exception('Errore nella ricerca dei dati'),
    ) as List<Map<String, dynamic>>;
  }


  /* -------------------------------- UTILITY PRIVATE METHODS ----------------------------- */

  /// Returns the path to the report(s) in the database for the given city and report ID.
  ///
  /// Parameters:
  /// - [city]: The name of the city.
  /// - [reportId]: The unique identifier of the report. If `null`, returns the path to all reports in the specified city.
  ///
  /// Returns:
  /// - A `String` representing the path to the report(s) in the database.
  String _getPath(String city, String? reportId) {
    if (reportId == null) {
      return 'reports/$city/${city}_reports';
    }
    return 'reports/$city/${city}_reports/$reportId';
  }

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
  bool _checkForUserValidity(String? city) {
    GenericUser? user = _userManagementDAO.getUser;
    if (user == null) {
      throw Exception('Utente non loggato!');
    }
    return (user is Municipality && (user).municipalityName == city) || user is Citizen;
  }

}