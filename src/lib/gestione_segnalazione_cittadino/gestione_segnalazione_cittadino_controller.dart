import 'dart:async';

import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/users_model.dart';
import 'gestione_segnalazione_cittadino_dao.dart';

/// Controller for managing citizen reports.
///
/// This controller provides methods to interact with the data access object (DAO)
/// for fetching and managing reports related to citizens.
class CitizenReportManagementController {
  /// Data Access Object (DAO) for managing citizen reports.
  late final CitizenReportManagementDAO _reportDAO;
  late final UserManagementDAO _userManagementDAO;
  late final Citizen _citizen;
  DocumentSnapshot? _lastDocument;
  final Completer<Citizen> _citizenCompleter = Completer<Citizen>();

  /// Constructs a new `CitizenReportManagementController` instance.
  /// [reportDAO] An optional instance of `CitizenReportManagementDAO`.
  /// If not provided, a new instance of `CitizenReportManagementDAO` will be created.
  /// [userManagementDAO] An optional instance of `UserManagementDAO`.
  /// If not provided, a new instance of `UserManagementDAO` will be created.

  CitizenReportManagementController({
    CitizenReportManagementDAO? reportDAO,
    UserManagementDAO? userManagementDAO,
  }) {
    _reportDAO = reportDAO ?? MockCitizenReportManagementDAO();
    _userManagementDAO = userManagementDAO ?? UserManagementDAO();
    _loadCitizen();
  }

  void _loadCitizen() async {
    try {
      final user = await _userManagementDAO.determineUserType();
      if (user == null) {
        throw Exception('User not logged in');
      }

      if (user is Citizen) {
        _citizen = user;
        _citizenCompleter.complete(user); // Segnala che l'inizializzazione è completa

      } else {
        throw Exception('User is not a citizen');
      }

    } catch (e) {
      _citizenCompleter.completeError('Error determining user type: $e');
    }
  }

  /// Restituisce il cittadino dopo che è stato inizializzato.
  Future<Citizen> get citizen async => _citizenCompleter.future;


  /// Fetches the list of reports for a given citizen.
  ///
  /// This method retrieves the list of reports associated with the city of the provided citizen.
  /// If the city is not available, it returns an empty list.
  ///
  /// \return A [Future] that resolves to a list of maps, where each map contains the report details.
  Future<List<Map<String, dynamic>>?> getUserReports() async {
    if(_citizen.city == null){
      return [];
    }

     List<Map<String, dynamic>>? snapshot = await _reportDAO.getReportList(
         city:_citizen.city!,
         lastDocument: _lastDocument
     );
    _lastDocument = snapshot?.last['documentSnapshot'];
    return snapshot;
  }
}
