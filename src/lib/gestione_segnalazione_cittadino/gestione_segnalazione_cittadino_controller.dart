import 'dart:async';

import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:civiconnect/utils/report_status_priority.dart';

import '../model/report_model.dart';
import '../model/users_model.dart';
import 'gestione_segnalazione_cittadino_dao.dart';

/// Controller for managing citizen reports.
///
/// This controller provides methods to interact with the data access object (DAO)
/// for fetching and managing reports related to citizens.
class CitizenReportManagementController {
  /// Data Access Object (DAO) for managing citizen reports.
  late final CitizenReportManagementDAO _reportDAO;
  late final UserManagementDAO _userManagementDAO;
  Citizen? _citizen;
  final Completer<Citizen> _citizenCompleter = Completer<Citizen>();

  /// Constructs a new `CitizenReportManagementController` instance.
  /// [reportDAO] An optional instance of `CitizenReportManagementDAO`.
  /// If not provided, a new instance of `CitizenReportManagementDAO` will be created.
  /// [userManagementDAO] An optional instance of `UserManagementDAO`.
  /// If not provided, a new instance of `UserManagementDAO` will be created.

  CitizenReportManagementController({
    CitizenReportManagementDAO? reportDAO,
    UserManagementDAO? userManagementDAO,
  }) {
    _reportDAO = reportDAO ?? CitizenReportManagementDAO();
    _userManagementDAO = userManagementDAO ?? UserManagementDAO();
    _loadCitizen();
  }

  /// Loads the current citizen user.
  ///
  /// This method determines the user type and initializes the `_citizen` field if the user is a citizen.
  ///
  /// Throws:
  /// - [Exception]: If the user is not logged in or is not a citizen.
  void _loadCitizen() async {
    try {
      final user = await _userManagementDAO.determineUserType();
      if (user == null) {
        throw Exception('User not logged in');
      }

      if (user is Citizen) {
        _citizen = user;
        _citizenCompleter.complete(user); // Segnala che l'inizializzazione è completa

      } else {
        throw Exception('User is not a citizen');
      }

    } catch (e) {
      _citizenCompleter.completeError('Error determining user type: $e');
    }
  }

  /// Returns the current citizen user.
  Future<Citizen> get citizen async => _citizenCompleter.future;


  /// Fetches the list of reports for a given citizen.
  ///
  /// This method retrieves the list of reports associated with the city of the provided citizen.
  /// If the city is not available, it returns an empty list.
  ///
  /// - [reset]: A `bool` indicating whether to reset the last document retrieved.
  ///   If the [reset] parameter is set to `true`, the method will reset the last document retrieved.
  ///
  /// Returns:
  /// - A [Future] that resolves to a list of maps, where each map contains the report details.
  Future<List<Map<String, dynamic>>?> getUserReports({bool reset = false}) async {
    if(_citizen == null || _citizen!.city == null){
      return [];
    }


    List<Map<String, dynamic>>? snapshot = await _reportDAO.getReportList(
        city:_citizen!.city!,
        reset: reset
    );
    return snapshot;
  }


  /// Fetches the list of reports for the current logged-in user.
  ///
  /// This method retrieves the list of reports associated with the current user.
  /// If the user is not available, it returns an empty list.
  ///
  /// - [reset]: A `bool` indicating whether to reset the last document retrieved.
  ///   If the [reset] parameter is set to `true`, the method will reset the last document retrieved.
  ///
  /// Returns:
  /// - A [Future] that resolves to a list of maps, where each map contains the report details.
  Future<List<Map<String, dynamic>>?> getMyReports({bool reset = false}) async {
    if (_citizen == null) {
      return [];
    }

    List<Map<String, dynamic>>? snapshot = await _reportDAO.getUserReportList(
      userId: _citizen!.uid,
      reset: reset,
    );
    return snapshot;
  }

  /// Filters the reports based on the specified criteria.
  /// This method filters the reports based on the specified status, priority, and category of a specified city.
  /// If no criteria are specified, it returns the list of all reports of the current city.
  ///
  /// Parameters:
  /// - [city]: The city to filter by.
  /// - [status]: The list of status criteria to filter by.
  /// - [priority]: The list of priority criteria to filter by.
  /// - [category]: The list of category criteria to filter by.
  ///
  /// Returns:
  /// - A [Future] that resolves to a list of maps, where each map contains the report details.
  /// - If no reports are found, it returns an empty list.
  /// - If the user is not valid, it returns `null`.
  Future<List<Map<String, dynamic>>?> filterReportsBy({required String city,
    List<StatusReport>? status,
    List<PriorityReport>? priority,
    List<Category>? category}) async {

    Map<String, List<dynamic>> criteria = {
    if (status != null) 'status': status.map((e) => e.name).toList(),
    if (priority != null)  'priority': priority.map((e) => e.name).toList(),
    if (category != null) 'category': category.map((e) => e.name).toList(),
    };

    List<Map<String, dynamic>>? snapshot = await _reportDAO.filterReportsBy(
        criteria: criteria,
        city: (_citizen != null) ? (city.isEmpty ? _citizen!.city ?? 'roma' : city) : 'roma');
    return snapshot;
  }

}
