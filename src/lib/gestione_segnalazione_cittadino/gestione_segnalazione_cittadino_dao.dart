import 'package:civiconnect/model/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CitizenReportManagementDAO {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

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
}
