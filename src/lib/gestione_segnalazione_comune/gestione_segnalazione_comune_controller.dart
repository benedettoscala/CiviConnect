import '../utils/report_status_priority.dart';
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
///
/// **Note**: Ensure proper permissions and authentication for Firestore operations.
///
/// @Author: [Your Name or Organization]
/// @Version: 1.0.0
class MunicipalityReportManagementController {
  /// An instance of `MunicipalityReportManagementDAO` to handle data operations.
  late final MunicipalityReportManagementDAO _reportDAO;

  /// Constructs a `MunicipalityReportManagementController`.
  ///
  /// If a `MunicipalityReportManagementDAO` instance is not provided, a new
  /// instance is initialized internally.
  ///
  /// ### Parameters:
  /// - `reportDAO`: An optional instance of `MunicipalityReportManagementDAO`
  ///   to be used by this controller. If not provided, a default instance is created.
  MunicipalityReportManagementController(
      {MunicipalityReportManagementDAO? reportDAO}) {
    _reportDAO = reportDAO ?? MunicipalityReportManagementDAO();
  }

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
    await _reportDAO.editReportStatus(
        city: city, reportId: reportId, newStatus: newStatus);
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
    await _reportDAO.editReportPriority(
        city: city, reportId: reportId, newPriority: newPriority);
  }
}
