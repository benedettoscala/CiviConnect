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
/// TC_7.0.1 invalid StatusReport Expected: changeStatus Fails
/// TC_7.0.2 StatusReport Scartata Expected: changeStatus Fails
/// TC_7.0.3 StatusReport current After new Expected: changeStatus Fails
/// TC_7.0.4 StatusReport current Before new and valid Expected: changeStatus is Accepted
/// dart run build_runner build
///

// Mock del ReportDAO
class MockReportDAO extends Mock implements MunicipalityReportManagementDAO {}

class MockUserDAO extends Mock implements UserManagementDAO {}

class MockBuildContext extends Mock implements BuildContext {}

class MockUser extends Mock implements User {}

Municipality m =
    Municipality(user: MockUser(), municipalityName: 'municipalityName');

Report r = Report(
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
    r.status = newStatus;
  }
}

void main() {
  /// TC_7.0.1 invalid StatusReport Expected: changeStatus Fails
  // enum not valid is tested by enum itself

  /// TC_7.0.2 StatusReport Scartata Expected: changeStatus Fails
  _testState(
      description:
          'TC_7.0.2 StatusReport Scartata Expected: changeStatus Fails',
      currentStatus: StatusReport.rejected,
      newStatus: StatusReport.inProgress,
      expectedStatus: StatusReport.rejected);

  /// TC_7.0.3 StatusReport current After new Expected: changeStatus Fails
  _testState(
      description:
          'TC_7.0.3 StatusReport current After new Expected: changeStatus Fails',
      currentStatus: StatusReport.completed,
      newStatus: StatusReport.inProgress,
      expectedStatus: StatusReport.completed);

  /// TC_7.0.4 StatusReport current Before new and valid Expected: changeStatus is Accepted
  _testState(
      description:
          'TC_7.0.3 StatusReport current After new Expected: changeStatus Fails',
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
    r.status = currentStatus;
    // Costruisci un widget con un contesto reale
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          final controller = MunicipalityReportManagementController.forTest(
            rdao: mockReportDAO,
            udao: mockUserDAO,
            context: context,
            m: m,
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

    expect(r.status, equals(expectedStatus));
  });
}