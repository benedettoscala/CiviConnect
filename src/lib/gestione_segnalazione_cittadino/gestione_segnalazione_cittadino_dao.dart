import 'package:civiconnect/model/report_model.dart';
import 'package:civiconnect/model/users_model.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Data Access Object (DAO) for managing citizen reports.
class CitizenReportManagementDAO {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

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
  CitizenReportManagementDAO({UserManagementDAO? userManagementDAO})
      : _userManagementDAO = userManagementDAO ?? UserManagementDAO();

  /// Retrieves a list of reports for a given city.
  ///
  /// Parameters:
  /// - [city]: The name of the city for which to retrieve the reports.
  /// - [reset]: A `bool` indicating whether to reset the last document retrieved (optional).
  ///
  /// Returns:
  /// - A `Future<List<Map<String, dynamic>>?>` containing the list of reports for the specified city, or `null` if the user is not valid.
  ///
  /// Throws:
  /// - [Exception]: If the user is not logged in.
  ///
  /// Preconditions:
  /// - The user must be logged in and either a `Municipality` with the specified city name or a `Citizen`.
  Future<List<Map<String, dynamic>>?> getReportList(
      {required String city, bool? reset}) async {
    if (reset == true) {
      _isEnded = false;
      _lastDocument = null;
    }

    if (!await _checkForUserValidity(city) || _isEnded) {
      return null;
    }

    return await _getTenReportsByOffset(city: city);
  }

  /// Adds a new report to the Firestore database.
  ///
  /// Parameters:
  /// - [reportData]: The report data to be added.
  ///
  /// Returns:
  /// - A `Future<bool>` indicating whether the report was successfully added.
  ///
  /// Throws:
  /// - [Exception]: If there is an error adding the report.
  Future<bool> addReport(Report reportData) async {
    try {
      await _firebaseFirestore
          .collection('reports')
          .doc(reportData.city?.toLowerCase())
          .collection('${reportData.city?.toLowerCase()}_reports')
          .add(reportData.toMap());
    } catch (e) {
      throw Exception('Failed to add report');
    }
    return true;
  }

  /// Retrieves a list of reports created by a specific user.
  ///
  /// Parameters:
  /// - [userId]: The ID of the user for which to retrieve the reports.
  /// - [reset]: A `bool` indicating whether to reset the last document retrieved (optional).
  ///
  /// Returns:
  /// - A `Future<List<Map<String, dynamic>>?>` containing the list of reports created by the specified user, or `null` if the user is not valid.
  ///
  /// Throws:
  /// - [Exception]: If the user is not logged in.
  Future<List<Map<String, dynamic>>?> getUserReportList(
      {required String userId}) async {
    return await _getReportsByUser(userId: userId);
  }

  /// Retrieves a list of reports for a given city filtered by the specified criteria.
  /// The criteria are specified as a map where the key is the field to filter by and the value is a list of values to filter.
  ///
  /// The reports are filtered by the specified criteria and the city.
  /// At a given time, all criteria are applied to a specific city.
  /// The criteria are combined with an AND operator.
  ///
  /// Parameters:
  /// - [criteria]: A map containing the criteria to filter by.
  ///   It is a map where the key is the field to filter by and the value is a list of values to filter.
  /// - [city]: The name of the city for which to retrieve the reports.
  /// - [reportDateStart]: An optional start date to filter the reports.
  /// - [reportDateEnd]: An optional end date to filter the reports.
  /// - [keyword]: An optional keyword to filter the reports by title or description.
  ///
  /// Returns:
  /// - A `Future<List<Map<String, dynamic>>?>` containing the list of reports for the specified city filtered by the criteria, or `null` if the user is not valid.
  Future<List<Map<String, dynamic>>?> filterReportsBy(
      {required Map<String, List<dynamic>> criteria,
      required String city,
      Timestamp? reportDateStart,
      Timestamp? reportDateEnd,
      String? keyword}) async {
    city = city.toLowerCase().trim();
    keyword = keyword?.toLowerCase().trim();

    Query<Map<String, dynamic>> query = _firestore
        .collection('reports')
        .doc(city.toLowerCase())
        .collection('${city.toLowerCase()}_reports');

    for (var key in criteria.keys) {
      if (criteria[key] != null && criteria[key]!.isNotEmpty) {
        query = query.where(key, whereIn: criteria[key]);
      }
    }

    List<Map<String, dynamic>>? results;
    try {
      final querySnapshot = await query.limit(100).get(); // Check limit

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      // Local Filtering Data since Firebase is not supporting OR operator
      // and it does not support string.contains or similar methods
      // Note: This is not efficient for large data
      // Note: could be done in the backend by using Algolia or ElasticSearch
      // or adding a new field with the concatenated data as an array in the report document
      results = querySnapshot.docs.map((doc) => doc.data()).toList();

      if (keyword != null && keyword.isNotEmpty) {
        results = results
            .where((report) =>
                report['title'].toLowerCase().contains(keyword!) ||
                report['description'].toLowerCase().contains(keyword))
            .toList();
      }

      // Date filter is applied after the keyword filter
      // It is applied locally since Firebase requires an index for composite queries for each document (city)
      if (reportDateStart != null) {
        reportDateEnd ??= Timestamp.now();
        results = results
            .where((report) =>
                reportDateStart.compareTo(report['reportDate']) <= 0 &&
                reportDateEnd!.compareTo(report['reportDate']) >= 0)
            .toList();
      }

      if (reportDateEnd != null) {
        query = query.where('reportDate', isLessThanOrEqualTo: reportDateEnd);
      }
    } catch (e) {
      return null;
    }
    return results;
  }

  /* --------------------------- PRIVATE METHODS ---------------------------------- */

  /// Retrieves the next ten reports for a given city, starting from the last retrieved report.
  ///
  /// Parameters:
  /// - [city]: The name of the city for which to retrieve the reports.
  ///
  /// Returns:
  /// - A `Future<List<Map<String, dynamic>>?>` containing the next ten reports for the specified city.
  ///
  /// Throws:
  /// - [Exception]: If there is an error retrieving the data.
  Future<List<Map<String, dynamic>>?> _getTenReportsByOffset(
      {required String city}) async {
    if (_isEnded) {
      return null;
    }

    Query<Map<String, dynamic>> query = _firestore
        .collection('reports')
        .doc(city.toLowerCase())
        .collection('${city.toLowerCase()}_reports')
        .orderBy('title', descending: true)
        .limit(10);

    // If the last document is not null, the query starts after the last document of the previous query.
    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    try {
      final querySnapshot = await query.get();
      // If the query is empty, the query is ended.
      if (querySnapshot.docs.isEmpty) {
        _isEnded = true;
        return null;
      }

      // If the query is less than 10, the query is ended but the last documents are updated.
      if (querySnapshot.docs.length < 10) {
        _isEnded = true;
      }

      // Update the last document.
      _lastDocument = querySnapshot.docs.last;

      //Retrieve the data from the query snapshot.
      var data = querySnapshot.docs.map((doc) {
        // Add the reportId to the data.
        final d = doc.data();
        d['reportId'] = doc.id;
        return d;
      }).toList();

      return data;
    } catch (e) {
      throw Exception('Error retrieving data: $e');
    }
  }

  ///
  /// Parameters:
  /// - [userId]: The ID of the user for which to retrieve the reports.
  ///
  /// Returns:

  /// - A \`Future<List<Map<String, dynamic>>?>\` containing the next ten reports created by the specified user, or \`null\` if the user is not valid.
  Future<List<Map<String, dynamic>>?> _getReportsByUser(
      {required String userId}) async {
    List<Map<String, dynamic>> allReports = [];
    try {
      // Get all city collections
      final cityCollections = await _firestore.collection('reports').get();
      for (var cityDoc in cityCollections.docs) {
        Query<Map<String, dynamic>> query = cityDoc.reference
            .collection('${cityDoc.id}_reports')
            .where('uid', isEqualTo: userId);

        final querySnapshot = await query.get();
        if (querySnapshot.docs.isNotEmpty) {
          allReports.addAll(querySnapshot.docs.map((doc) {
            // Add the reportId to the data.
            final d = doc.data();
            d['reportId'] = doc.id;
            return d;
          }).toList());
        }
      }

      if (allReports.isEmpty) {
        return null;
      }

      return allReports;
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
    return (user is Municipality && (user).municipalityName == city) ||
        user is Citizen;
  }
}
