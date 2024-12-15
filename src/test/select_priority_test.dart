import 'package:civiconnect/gestione_segnalazione_comune/gestione_segnalazione_comune_controller.dart';
import 'package:civiconnect/gestione_segnalazione_comune/gestione_segnalazione_comune_dao.dart';
import 'package:civiconnect/model/report_model.dart';
import 'package:civiconnect/model/users_model.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:civiconnect/utils/report_status_priority.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';  // Per gestire i messaggi di UI

/// Test Case fot the editPriorityReport method
///
/// TC_8.0_1: PriorityReport is unset field Expected: PriorityReport is not changed
/// TC_8.0_2: PriorityReport is high Expected: PriorityReport is changed to high
/// dart run build_runner build
///

// Mock del ReportDAO
class MockReportDAO extends Mock implements MunicipalityReportManagementDAO {}
class MockUserDAO extends Mock implements UserManagementDAO {}
class MockBuildContext extends Mock implements BuildContext {}
class MockUser extends Mock implements User {}

Municipality m= Municipality(user: MockUser(), municipalityName: 'municipalityName');

Report r= Report(
    city: 'testCity',
    reportId: 'report123',
    priority: PriorityReport.high,
    status: StatusReport.completed,
    title: 'title',
    description: 'description',
    reportDate:  Timestamp.now(),
    address: {'street': 'N/A', 'number': 'N/A'},
    location: const GeoPoint(0, 0),
    photo: '', uid: 'uid', authorFirstName: 'authorFirstName', authorLastName: 'authorLastName'
);

class FakeReportDAO extends Fake implements MunicipalityReportManagementDAO {
  @override
  Future<void> editReportPriority({required String city, required String reportId, required PriorityReport newPriority}) async {
    r.priority = newPriority;
  }

}

void main() {
  group('editReportPriority Tests', () {
    final mockReportDAO = FakeReportDAO();  // Istanza del mock del DAO
    final mockUserDAO=MockUserDAO();
    const city = 'testCity';
    const reportId = 'report123';
    PriorityReport newPriority = PriorityReport.unset;
    final initialPriority = r.priority;
    /// Test Case TC_8.0_1
    testWidgets('editReportPriority does not change the priority when priority is not high, medium, low', (tester) async {
      // Costruisci un widget con un contesto reale
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            final controller = MunicipalityReportManagementController.forTest(
              reportDao: mockReportDAO,
              userManagementDao: mockUserDAO,
              context: context,
              municipality: m,
            );

            return ElevatedButton(
              onPressed: () async {
                await controller.editReportPriority(
                  city: city,
                  reportId: reportId,
                  newPriority: newPriority,
                );
              },
              child: const Text('Test Button'),
            );
          }),
        ),
      ));

      // Esegui il tap sul bottone per scatenare la chiamata
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verifica che la priorità non sia stata cambiata
      expect(r.priority, equals(initialPriority));
    });

    /// Test Case TC_8.0_2
    testWidgets('editReportPriority changes the priority', (tester) async {
      PriorityReport newPriority = PriorityReport.high;
      // Costruisci un widget con un contesto reale
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            final controller = MunicipalityReportManagementController.forTest(
              reportDao: mockReportDAO,
              userManagementDao: mockUserDAO,
              context: context,
              municipality: m,
            );

            return ElevatedButton(
              onPressed: () async {
                await controller.editReportPriority(
                  city: city,
                  reportId: reportId,
                  newPriority: newPriority,
                );
              },
              child: const Text('Test Button'),
            );
          }),
        ),
      ));

      // Esegui il tap sul bottone per scatenare la chiamata
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verifica che la priorità non sia stata cambiata
      expect(r.priority, equals (newPriority));
    });
  });
}