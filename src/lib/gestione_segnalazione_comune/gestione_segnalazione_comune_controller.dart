import '../utils/report_status_priority.dart';
import 'gestione_segnalazione_comune_dao.dart';

class MunicipalityReportManagementController{
  late final MunicipalityReportManagementDAO _reportDAO;

  //wrapper for the DAO
  MunicipalityReportManagementController({MunicipalityReportManagementDAO? reportDAO}){
    _reportDAO = reportDAO ?? MunicipalityReportManagementDAO();
  }

  //edit the status of a report
  Future<void> editReportStatus({required String? city, required String? reportId, required StatusReport newStatus}) async {
    await _reportDAO.editReportStatus(city: city, reportId: reportId, newStatus: newStatus);
  }

  //edit the priority of a report
  Future<void> editReportPriority({required String? city, required String? reportId, required PriorityReport newPriority}) async {
    await _reportDAO.editReportPriority(city: city, reportId: reportId, newPriority: newPriority);
  }

}