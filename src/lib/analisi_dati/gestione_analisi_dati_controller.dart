import 'dart:async';

import 'package:civiconnect/analisi_dati/gestione_analisi_dati_dao.dart';
import 'package:civiconnect/model/users_model.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

/// Controller for managing data analysis.
/// The controller is used to retrieve data from the database
/// to be used in the data analysis for the municipality.
class DataAnalysisManagementController {
  final DataAnalysisManagementDAO _analysisDAO;
  final UserManagementDAO _userDAO;
  Municipality? _municipality;
  LatLng? _cityCoordinates;

  /// Constructs a new `DataAnalysisManagementController` instance.
  /// Parameters:
  /// - [analysisDAO]: An optional instance of `DataAnalysisManagementDAO`.
  /// If not provided, a new instance of `DataAnalysisManagementDAO` will be created.
  /// - [userDAO]: An optional instance of `UserManagementDAO`.
  /// If not provided, a new instance of `UserManagementDAO` will be created.
  DataAnalysisManagementController({DataAnalysisManagementDAO? analysisDAO, UserManagementDAO? userDAO}) :
        _analysisDAO = analysisDAO ?? DataAnalysisManagementDAO(),
        _userDAO = userDAO ?? UserManagementDAO();

  /// Retrieves the municipality user from the database.
  /// Returns the municipality user.
  /// Throws an exception if the user is not a municipality.
  Future<Municipality?> retrieveUser() async {
    // If the municipality is already available, return it.
    if(_municipality != null) {
      return _municipality;
    }
    // Retrieve the user from the database.
    final user = await _userDAO.determineUserType();
    if (user is Municipality) {
      _municipality = user;
    } else {
      throw Exception('User is not a municipality');
    }
    return _municipality;
  }

  /// Returns the name of the municipality.
/// If the municipality was not retrieved before, it is retrieved from the database.
Future<String?> cityOfMunicipality() async {
  _municipality ??= await retrieveUser();
  return _municipality?.municipalityName?.toLowerCase();
}

  /// Retrieves the data for the HeatMap from the database.
  /// - [city]: The name of the city for which to retrieve the data.
  /// Returns:
  /// - A `Future<List<WeightedLatLng>?>` containing the data for the HeatMap,
  /// or `null` if no data is available.
  Future<List<WeightedLatLng>?> dataHeatMap() async {
    final List<WeightedLatLng>? data = await _analysisDAO.retrieveDataHeatMap(city: await cityOfMunicipality())
        .then((data) => data);
    _cityCoordinates = data?.first.latLng;
    return data;
  }

  /// Retrieves the coordinates of the city of the municipality.
  /// Returns:
  /// - A `Future<Coordinates>` containing the coordinates of the city.
  Future<LatLng?> retrieveCityCoordinates() async {
    if(_cityCoordinates == null) {
      final city = await _analysisDAO.retrieveFirstReportLocation(city: await cityOfMunicipality());
      _cityCoordinates = city;
    }
    return _cityCoordinates;
  }

}