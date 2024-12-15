// This is the test for the status change of the report made by the municipality.

import 'package:civiconnect/gestione_segnalazione_comune/gestione_segnalazione_comune_controller.dart';
import 'package:civiconnect/gestione_segnalazione_comune/gestione_segnalazione_comune_dao.dart';
import 'package:civiconnect/model/report_model.dart';
import 'package:civiconnect/model/users_model.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:civiconnect/utils/report_status_priority.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

/// Test Case for Modifica Stato Segnalazione
///
///
/// TC_7.0_1 invalid StatusReport Expected: changeStatus Fails
/// TC_7.0_2 Transitions from 'completed' or 'rejected' are not allowed Expected: changeStatus Fails
/// TC_7.0_3 transition from state not 'In Verifica' to 'scartata' to  Expected: changeStatus Fails
/// TC_7.0_4 TC_7.0.4 transition to previus state Expected: changeStatus Fails
/// TC_7.0_5 transition non respecting correct order Expected: changeStatus Fails
/// TC_7.0_6 The current status in the StatusReport precedes the new status, adhering to the correct order Expected: changeStatus is Accepted
/// dart run build_runner build
///

// Mock del ReportDAO
class MockReportDAO extends Mock implements MunicipalityReportManagementDAO {}

class MockUserDAO extends Mock implements UserManagementDAO {}

class MockBuildContext extends Mock implements BuildContext {}

class MockUser extends Mock implements User {}

Municipality municipality =
    Municipality(user: MockUser(), municipalityName: 'municipalityName');

Report report = Report(
    city: 'testCity',
    reportId: 'report123',
    priority: PriorityReport.high,
    status: StatusReport.completed,
    title: 'title',
    description: 'description',
    reportDate: Timestamp.now(),
    address: {'street': 'N/A', 'number': 'N/A'},
    location: const GeoPoint(0, 0),
    photo: '',
    uid: 'uid',
    authorFirstName: 'authorFirstName',
    authorLastName: 'authorLastName');

class FakeReportDAO extends Fake implements MunicipalityReportManagementDAO {
  @override
  Future<void> editReportStatus({
    required String? city,
    required String? reportId,
    required StatusReport newStatus,
  }) async {
    report.status = newStatus;
  }
}

void main() {
  /// TC_7.0_1 invalid StatusReport Expected: changeStatus Fails
  // enum not valid is tested by enum itself

  /// TC_7.0_2 Transitions from 'completed' or 'rejected' are not allowed Expected: changeStatus Fails
  _testState(
      description:
          'TC_7.0_2 StatusReport from Rifiutata to other Expected: changeStatus Fails',
      currentStatus: StatusReport.rejected,
      newStatus: StatusReport.inProgress,
      expectedStatus: StatusReport.rejected);

  /// TC_7.0_3 transition from state not 'in attesa' to 'scartata' to  Expected: changeStatus Fails
  _testState(
      description:
          'TC_7.0_3 StatusReport from not in Attesa to Scartata Expected: changeStatus Fails',
      currentStatus: StatusReport.inProgress,
      newStatus: StatusReport.rejected,
      expectedStatus: StatusReport.inProgress);

  /// TC_7.0_4 transition to previus state Expected: changeStatus Fails
  _testState(
      description:
          'TC_7.0_4 StatusReport previous state Expected: changeStatus Fails',
      currentStatus: StatusReport.completed,
      newStatus: StatusReport.inProgress,
      expectedStatus: StatusReport.completed);

  /// TC_7.0_5 transition non respecting correct order Expected: changeStatus Fails
  _testState(
      description:
          'TC_7.0_5 StatusReport not respecting order Expected: changeStatus Fails',
      currentStatus: StatusReport.accepted,
      newStatus: StatusReport.completed,
      expectedStatus: StatusReport.accepted);

  /// TC_7.0_6 The current status in the StatusReport precedes the new status, adhering to the correct order Expected: changeStatus is Accepted
  _testState(
      description:
          'TC_7.0_6 StatusReport correct order new Expected: changeStatus is Accepted',
      currentStatus: StatusReport.inProgress,
      newStatus: StatusReport.completed,
      expectedStatus: StatusReport.completed);
}

void _testState(
    {required description,
    required StatusReport currentStatus,
    required StatusReport newStatus,
    required StatusReport expectedStatus}) {
  final mockReportDAO = FakeReportDAO(); // Istanza del mock del DAO
  final mockUserDAO = MockUserDAO();
  const city = 'testCity';
  const reportId = 'report123';

  testWidgets(description, (tester) async {
    report.status = currentStatus;
    // Costruisci un widget con un contesto reale
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          final controller = MunicipalityReportManagementController.forTest(
            reportDAO: mockReportDAO,
            userManagementDAO: mockUserDAO,
            context: context,
            municipality: municipality,
          );

          return ElevatedButton(
            onPressed: () async {
              await controller.editReportStatus(
                city: city,
                reportId: reportId,
                newStatus: newStatus,
                currentStatus: currentStatus,
              );
            },
            child: const Text('Test Button'),
          );
        }),
      ),
    ));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(report.status, equals(expectedStatus));
  });
}
