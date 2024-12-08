/* ========================================== MOCK CLASS ======================================================= */

import 'package:civiconnect/gestione_segnalazione_cittadino/gestione_segnalazione_cittadino_dao.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

/// Constructs a new `MockCitizenReportManagementDAO` instance.
///
/// Parameters:
/// - [userManagementDAO]: An optional instance of `UserManagementDAO`. If not provided, a new instance of `UserManagementDAO` will be created.
class MockCitizenReportManagementDAO extends Mock implements CitizenReportManagementDAO {
  /// The mock implementation of the `UserManagementDAO` class.
  /// Could be passed in the constructor.
  final UserManagementDAO userManagementDAO;

  /// The mock list of reports.
  late final List<Map<String, dynamic>> reports;

  /// The index of the last document retrieved. MOCK
  int _lastDocumentIndex = 0;

  /// Constructs a new `MockCitizenReportManagementDAO` instance.
  /// Parameters:
  /// - [userManagementDAO]: An optional instance of `UserManagementDAO`. If not provided, a new instance of `UserManagementDAO` will be created.
  MockCitizenReportManagementDAO({UserManagementDAO? userManagementDAO}) : userManagementDAO = userManagementDAO ?? UserManagementDAO(){
    Map<String, dynamic> report = {
      'reportId': '123',
      'uid': '456',
      'title': 'Test Report',
      'description': 'This is a test report',
      'photo': 'test.jpg',
      'address': {
        'street': 'Main St',
        'number': '123',
      },
      'location': const GeoPoint(0.0, 0.0),
      'city': 'Test City',
      'category': 'Illuminazione',
      'status': 'In Lavorazione',
      'authorFirstName': 'John',
      'authorLastName': 'Doe',
    };

    reports = [];
    for(int i = 0; i < 30; i++) {
      Map<String, dynamic> r = Map.from(report);
      r['uid'] = i.toString();
      reports.add(r);
    }

  }

  @override
  Future<List<Map<String, dynamic>>?> getReportList({required String city, bool? reset}) async {
    if(reset == true){
      _lastDocumentIndex = 0;
    }

    if(_lastDocumentIndex >= 30){
      return Future.value(null);
    }

    int index = _lastDocumentIndex;
    _lastDocumentIndex = index + 10;
    return Future.value(reports.sublist(index, index + 10));
  }



}
