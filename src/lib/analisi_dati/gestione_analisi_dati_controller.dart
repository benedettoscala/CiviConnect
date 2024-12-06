import 'package:civiconnect/analisi_dati/gestione_analisi_dati_dao.dart';
import 'package:civiconnect/model/users_model.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';


class DataAnalysisManagementController {
  final DataAnalysisManagementDAO _analysisDAO;
  final UserManagementDAO _userDAO;
  Municipality? _municipality;

  DataAnalysisManagementController( DataAnalysisManagementDAO? analysisDAO, UserManagementDAO? userDAO) :
        _analysisDAO = analysisDAO ?? DataAnalysisManagementDAO(),
        _userDAO = userDAO ?? UserManagementDAO();

  /// Retrieves the municipality user from the database.
  /// Returns the municipality user.
  /// Throws an exception if the user is not a municipality.
  Municipality? retrieveUser() {
    _userDAO.determineUserType().then((user) {
        if(user is Municipality) {
          _municipality = user;
        } else {
          throw Exception('User is not a municipality');
        }
    });
    return _municipality;
  }

  /// Returns the name of the municipality.
  /// If the municipality was not retrieved before, it is retrieved from the database.
  String? cityOfMunicipality() {
    if(_municipality == null) {
      retrieveUser();
    }
    return _municipality?.city;
  }

}