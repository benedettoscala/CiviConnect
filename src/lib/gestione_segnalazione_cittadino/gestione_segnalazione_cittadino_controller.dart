import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/report_model.dart';
import '../utils/report_status_priority.dart';
import 'gestione_segnalazione_cittadino_DAO.dart';

class CitizenReportManagementController {
  final Widget redirectPage;

  CitizenReportManagementController({required this.redirectPage});
  final CitizenReportManagementDAO _reportDAO = CitizenReportManagementDAO();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> addReport(BuildContext context,
      {required String citta,
      required String titolo,
      required String descrizione,
      required Category categoria,
      required GeoPoint location,
      Map<String, String>? indirizzo}) async {
    print('$indirizzo nel controller');
    final report = Report(
      uid: _firebaseAuth.currentUser!.uid,
      city: citta,
      title: titolo,
      description: descrizione,
      category: categoria,
      reportDate: Timestamp.now(),
      address: indirizzo,
      location: location,
      status: StatusReport.inProgress,
      priority: PriorityReport.low,
      authorFirstName: '',
      authorLastName: '',
      photo: '',
      endDate: null,
    );
    final bool result = await _reportDAO.addReport(report);
    if (result) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => redirectPage),
        (route) => false,
      );
    }
  }
}
