import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/report_model.dart';
import '../model/users_model.dart';
import '../user_management/user_management_dao.dart';
import '../utils/report_status_priority.dart';
import '../utils/snackbar_riscontro.dart';
import 'gestione_segnalazione_comune_dao.dart';

/// The `MunicipalityReportManagementController` class provides a controller
/// for managing municipality reports. It acts as a wrapper around the
/// `MunicipalityReportManagementDAO` class, facilitating higher-level
/// operations on municipality reports.
///
/// This class is responsible for delegating the management of report status
/// and priority updates to the underlying DAO, offering a simplified interface
/// for application-level interactions.
///
/// ## Usage Example:
/// ```dart
/// final reportController = MunicipalityReportManagementController();
///
/// // Update the status of a report
/// await reportController.editReportStatus(
///   city: 'NewYork',
///   reportId: 'report123',
///   newStatus: StatusReport.completed,
/// );
///
/// // Update the priority of a report
/// await reportController.editReportPriority(
///   city: 'NewYork',
///   reportId: 'report123',
///   newPriority: PriorityReport.high,
/// );
/// ```
class MunicipalityReportManagementController {
  /// The page to navigate to after certain actions, such as adding a report.
  final Widget? redirectPage;

  /// An instance of `MunicipalityReportManagementDAO` to handle data operations.
  final MunicipalityReportManagementDAO _reportDAO;
  final UserManagementDAO _userManagementDAO;
  final BuildContext? _context;
  Municipality? _municipality;
  final Completer<Municipality> _municipalityCompleter =
      Completer<Municipality>();

  /// Constructs a `MunicipalityReportManagementController`.
  ///
  /// This constructor initializes the controller and loads the municipality data.
  ///
  /// ### Parameters:
  /// - `redirectPage`: The page to redirect to after loading the municipality data.
  MunicipalityReportManagementController(
      {reportDAO, userManagementDAO, this.redirectPage, context})
      : _context = context,
        _reportDAO = reportDAO ?? MunicipalityReportManagementDAO(),
        _userManagementDAO = userManagementDAO ?? UserManagementDAO() {
    _loadMunicipality();
  }

  /// Constructs a `MunicipalityReportManagementController` for testing purposes.
  ///
  /// This constructor initializes the controller with mock data for testing.
  ///
  /// ### Parameters:
  /// - `rdao`: The mock DAO for report management.
  /// - `udao`: The mock DAO for user management.
  /// - `m`: The mock municipality data.
  /// - `redirectPage`: The page to redirect to after loading the municipality data.
  /// - `context`: The build context for showing messages.
  MunicipalityReportManagementController.forTest({
    reportDAO,
    userManagementDAO,
    municipality,
    this.redirectPage,
    context,
  })  : _reportDAO = reportDAO,
        _context = context,
        _userManagementDAO = userManagementDAO,
        _municipality = municipality;

  /// Edits the status of a specific report.
  ///
  /// This method delegates the update of the report's status to the DAO. It updates
  /// the `status` field of a specific report document in the Firestore collection
  /// corresponding to the given city.
  ///
  /// ### Parameters:
  /// - `city`: The name of the city where the report is located (case insensitive).
  /// - `reportId`: The unique identifier of the report.
  /// - `newStatus`: The new status to set for the report. This should be of type `StatusReport`.
  ///
  /// ### Returns:
  /// A `Future<void>` that completes when the operation is successful.
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
    required String city,
    required String reportId,
    required StatusReport newStatus,
    required StatusReport currentStatus,
  }) async {
    try {
      isValidStatusChange(currentStatus, newStatus);
      await _reportDAO.editReportStatus(
          city: city, reportId: reportId, newStatus: newStatus);
      if (_context != null) {
        showMessage(
          _context,
          message: 'Stato aggiornato correttamente.',
        );
      }
    } catch (e) {
      if (_context != null) {
        showMessage(
          _context,
          message: e,
          isError: true,
        );
      }
    }
  }

  /// Checks if the status change is valid.
  /// This method checks if the status change is valid based on the current and new status.
  /// If the status change is not valid, it throws an exception with the corresponding error message.
  /// The following rules are enforced:
  /// 1. Transitions from 'completed' or 'rejected' are not allowed.
  /// 2. 'rejected' can only be accessed from 'underReview'.
  /// 3. Ensure the new status follows the correct order.
  /// 4. Check if newStatus is within the valid range.
  /// Parameters:
  /// - [currentStatus]: The current status of the report.
  /// - [newStatus]: The new status to set for the report.
  /// Throws:
  /// - An exception with the corresponding error message if the status change is not valid.
  /// Example:
  /// ```dart
  /// isValidStatusChange(
  ///  currentStatus: StatusReport.underReview,
  ///  newStatus: StatusReport.accepted,
  ///  );
  ///  ```
  ///  This example checks if the status change from 'underReview' to 'accepted' is valid.
  ///  If the status change is not valid, it throws an exception with the corresponding error message.
  ///  ```dart
  ///  isValidStatusChange(
  ///  currentStatus: StatusReport.inProgress,
  ///  newStatus: StatusReport.completed,
  ///  );
  ///  ```
  void isValidStatusChange(StatusReport currentStatus, StatusReport newStatus) {
    // Get the indices of the current and new status
    final currentStatusIndex = currentStatus.index;
    final newStatusIndex = newStatus.index;

    // Rule 1: Transitions from 'completed' or 'rejected' are not allowed
    if (currentStatus == StatusReport.completed ||
        currentStatus == StatusReport.rejected) {
      throw ('Transizione da stato ${currentStatus.name} non consentita.');
    }

    // Rule 2: 'rejected' can only be accessed from 'underReview'
    if (newStatus == StatusReport.rejected &&
        currentStatus != StatusReport.underReview) {
      throw ('La transizione a "Rifiutata" è consentita solo dallo stato "In Verifica".');
    }

    // Rule 3: Ensure the new status follows the correct order
    if (newStatusIndex != currentStatusIndex + 1 &&
        newStatus != StatusReport.rejected) {
      throw ('Transizione non valida. Lo stato successivo consentito è ${StatusReport.values[currentStatusIndex + 1].name}.');
    }

    // Rule 4: Check if newStatus is within the valid range
    if (newStatusIndex < StatusReport.underReview.index ||
        newStatusIndex > StatusReport.rejected.index) {
      throw ('Stato non valido: ${newStatus.name}');
    }
  }

  /// Edits the priority of a specific report.
  ///
  /// This method delegates the update of the report's priority to the DAO. It updates
  /// the `priority` field of a specific report document in the Firestore collection
  /// corresponding to the given city.
  ///
  /// ### Parameters:
  /// - `city`: The name of the city where the report is located (case insensitive).
  /// - `reportId`: The unique identifier of the report.
  /// - `newPriority`: The new priority to set for the report. This should be of type `PriorityReport`.
  ///
  /// ### Returns:
  /// A `Future<void>` that completes when the operation is successful.
  ///
  /// ### Example:
  /// ```dart
  /// await editReportPriority(
  ///   city: 'LosAngeles',
  ///   reportId: 'xyz789',
  ///   newPriority: PriorityReport.high,
  /// );
  /// ```
  Future<void> editReportPriority({
    required String city,
    required String reportId,
    required PriorityReport newPriority,
  }) async {
    try {
      if (newPriority == PriorityReport.high ||
          newPriority == PriorityReport.low ||
          newPriority == PriorityReport.medium) {
        await _reportDAO.editReportPriority(
            city: city, reportId: reportId, newPriority: newPriority);
        if (_context != null) {
          showMessage(
            _context,
            message: 'Priorità segnalazione cambiata',
          );
        }
      } else {
        if (_context != null) {
          showMessage(
            _context,
            message: 'Errore durante l\'aggiornamento della priorità',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (_context != null) {
        showMessage(
          _context,
          message: 'Errore durante l\'aggiornamento della priorità',
          isError: true,
        );
      }
    }
  }

  /// Loads the municipality data.
  /// This method loads the municipality data from the Firestore database.
  /// If the user is not logged in or is not a municipality, it throws an exception.
  /// If the municipality data is successfully loaded, it completes the `_municipalityCompleter`.
  void _loadMunicipality() async {
    try {
      final user = await _userManagementDAO.determineUserType();
      if (user == null) {
        throw Exception('User not logged in');
      }

      if (user is Municipality) {
        _municipality = user;
        _municipalityCompleter
            .complete(user); // Segnala che l'inizializzazione è completa
      } else {
        throw Exception('User is not a citizen');
      }
    } catch (e) {
      _municipalityCompleter.completeError('Error determining user type: $e');
    }
  }

  /// Returns the current citizen user.
  Future<Municipality> get municipality async => _municipalityCompleter.future;

  /// Retrieves the list of municipality reports.
  ///
  /// This method fetches the list of reports for the current municipality.
  /// If the municipality is not set or its name is null, an empty list is returned.
  ///
  /// ### Parameters:
  /// - `reset`: A boolean flag indicating whether to reset the report list. Defaults to `false`.
  ///
  /// ### Returns:
  /// A `Future` that completes with a list of maps containing the report data, or an empty list if the municipality is not set.
  Future<List<Map<String, dynamic>>?> getMunicipalityReports(
      {bool reset = false}) async {
    if (_municipality == null || _municipality!.municipalityName == null) {
      return [];
    }

    List<Map<String, dynamic>>? snapshot = await _reportDAO.getReportList(
      city: _municipality!.municipalityName!,
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
  /// - [dateRange]: The date range to filter by, used as [startDate, endDate].
  ///
  /// Returns:
  /// - A [Future] that resolves to a list of maps, where each map contains the report details.
  /// - If no reports are found, it returns an empty list.
  /// - If the user is not valid, it returns `null`.
  Future<List<Map<String, dynamic>>?> filterReportsBy(
      {List<StatusReport>? status,
      List<PriorityReport>? priority,
      List<Category>? category,
      DateTimeRange? dateRange,
      String? keyword}) async {
    if (_municipality == null || _municipality!.municipalityName == null) {
      return null;
    }

    Map<String, List<dynamic>> criteria = {
      if (status != null) 'status': status.map((e) => e.name).toList(),
      if (priority != null) 'priority': priority.map((e) => e.name).toList(),
      if (category != null) 'category': category.map((e) => e.name).toList(),
    };
    Timestamp? startRange;
    Timestamp? endRange;

    if (dateRange != null) {
      startRange = Timestamp.fromDate(dateRange.start);
      endRange = Timestamp.fromDate(dateRange.end);
    }

    List<Map<String, dynamic>>? snapshot =
        await _reportDAO.filterMunicipalityReportsBy(
            criteria: criteria,
            keyword: keyword,
            reportDateStart: startRange,
            reportDateEnd: endRange,
            city: _municipality!.municipalityName!);
    return snapshot;
  }
}
