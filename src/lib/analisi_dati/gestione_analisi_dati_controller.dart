import 'dart:async';

import 'package:civiconnect/analisi_dati/gestione_analisi_dati_dao.dart';
import 'package:civiconnect/model/users_model.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    // Controlla se le coordinate sono già state recuperate e memorizzate nella cache
    if (_cityCoordinates != null) {
      return _cityCoordinates;
    }

    try {
      // Recupera il nome della città associato al municipio
      final cityName = await cityOfMunicipality();

      if (cityName == null) {
        return null;
      }

      // Costruisce l'URL per la chiamata a Nominatim
      const String url = 'https://nominatim.openstreetmap.org/search';
      final Map<String, String> queryParameters = {
        'q': cityName,
        'format': 'json',
        'limit': '1',
      };

      // Costruisce il URI con i parametri
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);

      // Effettua la richiesta GET
      final response = await http.get(uri, headers: {
          'User-Agent': 'CiviConnect/1.0 (civiconnect.unisa@gmail.com)' // Specifica un User-Agent
      });

      // Controlla se la risposta è valida
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          // Estrai latitudine e longitudine
          final double latitude = double.parse(data[0]['lat']);
          final double longitude = double.parse(data[0]['lon']);

          // Memorizza le coordinate nella cache
          _cityCoordinates = LatLng(latitude, longitude);
          return _cityCoordinates;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Retrieves the data for the analysis.
  /// The data is retrieved from the database and analyzed based on the data partition.
  /// - [dataPartition]: The data partition to use for the analysis.
  /// Returns:
  /// - A `Future<Map<String, double>?>` containing the partitioned data.
  /// - If no data is available, returns `null`.
  Future<Map<String, double>?> retrieveDataForAnalysis(
      DataPartition dataPartition) async {
    final data = await _analysisDAO.retrieveDataForAnalysis(
        city: await cityOfMunicipality(), dataPartition: dataPartition);
    return data;
  }
}