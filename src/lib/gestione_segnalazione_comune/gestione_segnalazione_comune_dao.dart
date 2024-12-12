import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

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
  /// Instance of Firebase Firestore for database operations.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      try {
        await _firestore
            .collection('reports')
            .doc(city?.toLowerCase())
            .collection('${city?.toLowerCase()}_reports')
            .doc(reportId)
            .update({'status': newStatus.name()});
      } catch (e) {
        throw const PermissionDeniedException(
          'You do not have the permissions to modify the priority of the report',
        );
      }
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
}
