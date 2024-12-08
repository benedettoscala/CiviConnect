import 'dart:async';


import 'package:civiconnect/utils/report_status_priority.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


/// Data Access Object (DAO) for managing municipality reports.
class MunicipalityReportManagementDAO {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> editReportStatus(
      {required String? city,
      required String? reportId,
      required StatusReport newStatus}) async {
    // Access the Firestore collection for reports
    await _firestore
        .collection('reports')
        .doc(city?.toLowerCase())
        .collection('${city?.toLowerCase()}_reports')
        .doc(reportId)
        .update({'status': newStatus.name()});
  }

  Future<void> editReportPriority(
      {required String? city,
        required String? reportId,
        required PriorityReport newPriority}) async {
    try {
      // Access the Firestore collection for reports
      await _firestore
          .collection('reports')
          .doc(city?.toLowerCase())
          .collection('${city?.toLowerCase()}_reports')
          .doc(reportId)
          .update({'priority': newPriority.name});
    } catch (e) {
      //messaggio temporaneo per testing
      print('city: ${city?.toLowerCase()}\nreportId ${reportId}\nnewPriority ${newPriority}');
    }
  }



}
