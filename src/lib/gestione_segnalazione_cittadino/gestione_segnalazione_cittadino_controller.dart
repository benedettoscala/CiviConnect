import '../model/users_model.dart';
import 'gestione_segnalazione_cittadino_dao.dart';


/// Controller for managing citizen reports.
///
/// This controller provides methods to interact with the data access object (DAO)
/// for fetching and managing reports related to citizens.
class CitizenReportManagementController{
  final CitizenReportManagementDAO _reportDAO = CitizenReportManagementDAO();

  /// Fetches the list of reports for a given citizen.
  ///
  /// This method retrieves the list of reports associated with the city of the provided citizen.
  /// If the city is not available, it returns an empty list.
  ///
  /// \param user The [Citizen] object representing the user whose reports are to be fetched.
  ///
  /// \return A [Future] that resolves to a list of maps, where each map contains the report details.
  Future<List<Map<String, dynamic>>?> getUserReports(Citizen user) async {
    return await _reportDAO.getReportList(user.city ?? '');
  }
}