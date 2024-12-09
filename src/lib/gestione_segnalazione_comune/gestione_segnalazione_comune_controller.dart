import 'package:flutter/material.dart';

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
  /// An instance of `MunicipalityReportManagementDAO` to handle data operations.
  final MunicipalityReportManagementDAO _reportDAO;
  final BuildContext? _context;

  /// Constructs a `MunicipalityReportManagementController`.
  ///
  /// If a `MunicipalityReportManagementDAO` instance is not provided, a new
  /// instance is initialized internally.
  ///
  /// ### Parameters:
  /// - `reportDAO`: An optional instance of `MunicipalityReportManagementDAO`
  ///   to be used by this controller. If not provided, a default instance is created.
  /// - `context`: An optional `BuildContext` to be used for UI operations.
  ///  This is required for displaying messages or dialogs.
  MunicipalityReportManagementController({reportDAO, context})
      : _reportDAO = reportDAO ?? MunicipalityReportManagementDAO(),
        _context = context;

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
  }) async {
    try {
      await _reportDAO.editReportStatus(
          city: city, reportId: reportId, newStatus: newStatus);
      if (_context != null) {
        showMessage(
          _context,
          message: 'Stato aggiornato correttamente',
          isError: true,
        );
      }
    } catch (e) {
      if (_context != null) {
        showMessage(
          _context,
          message: 'Errore durante l\'aggiornamento dello stato',
          isError: true,
        );
      }
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
      await _reportDAO.editReportPriority(
          city: city, reportId: reportId, newPriority: newPriority);
      if (_context != null) {
        showMessage(
          _context,
          message: 'Priorità segnalazione cambiata',
        );
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
}
