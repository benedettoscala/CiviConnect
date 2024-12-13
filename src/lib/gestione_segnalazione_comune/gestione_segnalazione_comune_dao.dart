import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../model/users_model.dart';
import '../user_management/user_management_dao.dart';
import '../utils/report_status_priority.dart';

/// The `MunicipalityReportManagementDAO` class provides a Data Access Object (DAO)
/// for managing municipality reports stored in Firestore. This class enables
/// operations to edit the status and priority of specific municipality reports.
///
/// It interacts with a Firestore database where reports are categorized by city
/// and stored in specific collections.
///
/// ## Usage Example:
/// ```dart
/// final reportDAO = MunicipalityReportManagementDAO();
///
/// await reportDAO.editReportStatus(
///   city: 'NewYork',
///   reportId: 'report123',
///   newStatus: StatusReport.completed,
/// );
///
/// await reportDAO.editReportPriority(
///   city: 'NewYork',
///   reportId: 'report123',
///   newPriority: PriorityReport.high,
/// );
/// ```
class MunicipalityReportManagementDAO {
  //final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  /// The data access object for user management.
  final UserManagementDAO _userManagementDAO;
  /// The Firestore instance.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  /// The last document retrieved in the previous query.
  DocumentSnapshot? _lastDocument;

  /// Specifies it the query offset is at the bottom of the list.
  bool _isEnded = false;

  /// Constructs a new `CitizenReportManagementDAO` instance.
  ///
  /// Parameters:
  /// - [userManagementDAO]: An optional instance of `UserManagementDAO`. If not provided, a new instance of `UserManagementDAO` will be created.
  MunicipalityReportManagementDAO({UserManagementDAO? userManagementDAO}) : _userManagementDAO = userManagementDAO ?? UserManagementDAO();

  /// Retrieves a list of reports for a given city.
  ///
  /// Parameters:
  /// - [city]: The name of the city for which to retrieve the reports.
  /// - [lastDocument]: The last document retrieved in the previous query (optional).
  ///
  /// Returns:
  /// - A `Future<List<Map<String, dynamic>>?>` containing the list of reports for the specified city, or `null` if the user is not valid.
  ///
  /// Throws:
  /// - [Exception]: If the user is not logged in.
  ///
  /// Preconditions:
  /// - The user must be logged in and either a `Municipality` with the specified city name or a `Citizen`.
  Future<List<Map<String, dynamic>>?> getReportList({required String city, bool? reset}) async {
    if(reset == true){
      _isEnded = false;
      _lastDocument = null;
    }

    if(! await _checkForUserValidity(city) || _isEnded){
      return null;
    }

    return await _getTenReportsByOffset(city: city);
  }

  /// Updates the status of a specific report in the Firestore database.
  ///
  /// This method updates the `status` field of a specified report document within
  /// the Firestore collection for the given city.
  ///
  /// ### Parameters:
  /// - `city`: The name of the city where the report is located (case insensitive).
  /// - `reportId`: The unique identifier of the report.
  /// - `newStatus`: The new status to set for the report. This should be of type `StatusReport`.
  ///
  /// ### Returns:
  /// A `Future<void>` that completes when the update operation is successful.
  ///
  /// ### Exceptions:
  /// Throws an error if the Firestore operation fails, such as when the specified
  /// report or city collection does not exist.
  ///
  /// ### Example:
  /// ```dart
  /// await editReportStatus(
  ///   city: 'SanFrancisco',
  ///   reportId: 'abc123',
  ///   newStatus: StatusReport.resolved,
  /// );
  /// ```
  Future<void> editReportStatus({
    required String? city,
    required String? reportId,
    required StatusReport newStatus,
  }) async {
    try {
      await _firestore
          .collection('reports')
          .doc(city?.toLowerCase())
          .collection('${city?.toLowerCase()}_reports')
          .doc(reportId)
          .update({'status': newStatus.name});
    } catch (e) {
      throw const PermissionDeniedException(
          'You do not have the permissions to modify the status of the report');
    }
  }

  /// Updates the priority of a specific report in the Firestore database.
  ///
  /// This method updates the `priority` field of a specified report document within
  /// the Firestore collection for the given city.
  ///
  /// ### Parameters:
  /// - `city`: The name of the city where the report is located (case insensitive).
  /// - `reportId`: The unique identifier of the report.
  /// - `newPriority`: The new priority to set for the report. This should be of type `PriorityReport`.
  ///
  /// ### Returns:
  /// A `Future<void>` that completes when the update operation is successful.
  ///
  /// ### Exceptions:
  /// Throws a `PermissionDeniedException` if the user does not have permission to
  /// modify the priority of the report. This may occur due to insufficient Firestore
  /// permissions.
  ///
  /// ### Example:
  /// ```dart
  /// try {
  ///   await editReportPriority(
  ///     city: 'LosAngeles',
  ///     reportId: 'xyz789',
  ///     newPriority: PriorityReport.critical,
  ///   );
  /// } catch (e) {
  ///   print('Permission error: $e');
  /// }
  /// ```
  Future<void> editReportPriority({
    required String city,
    required String reportId,
    required PriorityReport newPriority,
  }) async {
    try {
      await _firestore
          .collection('reports')
          .doc(city.toLowerCase())
          .collection('${city.toLowerCase()}_reports')
          .doc(reportId)
          .update({'priority': newPriority.name});
    } catch (e) {
      throw const PermissionDeniedException(
        'You do not have the permissions to modify the priority of the report',
      );
    }
  }

  /* --------------------------- PRIVATE METHODS ---------------------------------- */

  /// Retrieves the next ten reports for a given city, starting from the last retrieved report.
  ///
  /// Parameters:
  /// - [city]: The name of the city for which to retrieve the reports.
  /// - [lastDocument]: The last document retrieved in the previous query (optional).
  ///
  /// Returns:
  /// - A `Future<List<Map<String, dynamic>>>` containing the next ten reports for the specified city.
  ///
  /// Throws:
  /// - [Exception]: If there is an error retrieving the data.
  Future<List<Map<String, dynamic>>?> _getTenReportsByOffset({required String city}) async {
    Query<Map<String, dynamic>> query = _firestore.collection('reports').doc(city.toLowerCase()).collection('${city.toLowerCase()}_reports')
        .orderBy('title', descending: true).limit(10);

    // If the last document is not null, the query starts after the last document of the previous query.
    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    try {
      final querySnapshot = await query.get();
      // If the query is empty or the last document is the same as the previous one, the query is ended.
      if (_isEnded || querySnapshot.docs.isEmpty || _lastDocument == querySnapshot.docs.last){
        _isEnded = true;
        return null;
      }

      //Retrieve the data from the query snapshot.
      var data = querySnapshot.docs.map((doc) {
        // Add the reportId to the data.
        final d = doc.data();
        d['reportId'] = doc.id;
        return d;
      }
      ).toList();
      // Update the last document.
      _lastDocument  = querySnapshot.docs.last;


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
