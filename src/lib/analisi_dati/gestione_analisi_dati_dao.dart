import 'package:civiconnect/utils/report_status_priority.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

/// The data partition to use for the analysis.
/// The data partition is used to divide the data into different categories.
/// The categories are:
/// - Priority
/// - Status
/// - Category
enum DataPartition {
  /// Analyze data by priority of the reports.
  priority,
  /// Analyze data by status of the reports.
  status,
  /// Analyze data by category of the reports.
  category
}


/// Data Access Object (DAO) for managing data analysis.
/// The DAO is used to retrieve data from the database
/// to be used in the data analysis for the municipality.
class DataAnalysisManagementDAO {

  /// The Firestore instance.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// The HeatMap data retrieved from the database.
  /// Whe DAO is used to retrieve the data, the data is stored in this variable to cache it.
  List<WeightedLatLng>? _data;

  /// The document snapshot retrieved from the database.
  /// It contains all reports for a specific city.
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _docs;

  /// The default point to use if no data is available.
  /// This point is the coordinates of Fisciano City.
  final _defaultPoint = const GeoPoint(40.773837, 14.7884);

  /// Retrieves the data for the HeatMap from the database.
  /// - [city]: The name of the city for which to retrieve the data.
  /// Returns:
  /// - A `Future<List<WeightedLatLng>?>` containing the data for the HeatMap,
  /// or `null` if no data is available.
  Future<List<WeightedLatLng>?> retrieveDataHeatMap({String? city}) async {
    // If the data is already available, return it.
    if(_data != null){
      return _data;
    }

    // Retrieve the data from the database.
    final docs = await _retrieveReports(city: city);

    // If no data is available, return null.
    if(docs.isEmpty){
      return null;
    }
    // The data is stored in a list of WeightedLatLng objects.
    _data = docs.map((doc) {
      GeoPoint point = doc.data()['location'] ??_defaultPoint;
        return WeightedLatLng(
        LatLng(point.latitude, point.longitude),
        PriorityReport.getPriority(doc.data()['priority']?? 'Non impostata')!.value.ceilToDouble());}
    ).toList();

    return _data;
  }

  /// Retrieves the coordinates of the city of the municipality.
  /// - [city]: The name of the city for which to retrieve the coordinates.
  /// Returns:
  /// - A `Future<LatLng>` containing the coordinates of the city,
  /// or `LatLng(40.773837, 14.7884)` (Fisciano City) if no coordinates are available.
  /// The coordinates are retrieved from the first report in the database.
  Future<LatLng> retrieveFirstReportLocation({String? city}){
    return _firestore.collection('reports').doc(city).collection('${city}_reports').get().then((querySnapshot) {
      final docs = querySnapshot.docs;
      if(docs.isEmpty){
        return LatLng(_defaultPoint.latitude, _defaultPoint.longitude);
      }
      final point = docs.first.data()['location'] ?? _defaultPoint;
      return LatLng(point.latitude, point.longitude);
    });
  }

  /// Retrieves the data for the analysis.
  /// The data is retrieved from the database and analyzed based on the data partition.
  /// - [city]: The name of the city for which to retrieve the data.
  /// - [dataPartition]: The data partition to use for the analysis.
  /// Returns:
  /// - A `Future<Map<String, double>?>` containing the partitioned data.
  Future<Map<String, double>?> retrieveDataForAnalysis({
    String? city,
    DataPartition? dataPartition,
  }) async {

    if(_docs == null){
      await _retrieveReports(city: city);
    }

    if(_docs!.isEmpty){
      return null;
    }

    switch(dataPartition){
      case DataPartition.status:
        return _analyzeDataBy('status');
      case DataPartition.category:
        return _analyzeDataBy('category');
      case DataPartition.priority:
        return _analyzeDataBy('priority');
      default:
        return null;
    }

  }


  /* ----------------- Private methods ----------------- */

  /// Retrieves all reports for a specific city.
  /// - [city]: The name of the city for which to retrieve the reports.
  /// Returns:
  /// - A `Future<QuerySnapshot>` containing all reports for the city.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _retrieveReports({String? city}) async {
    // Retrieve the data from the database.
    final querySnapshot = await _firestore.collection('reports').doc(city).collection('${city}_reports').get();
    final docs = querySnapshot.docs;
    _docs = docs;
    return docs;
  }

  /// Analyzes the data based on a specific characteristic.
  /// - [characteristic]: The characteristic to use for the analysis.
  /// Returns:
  /// - A `Map<String, double>` containing the analyzed data.
  Map<String, double> _analyzeDataBy(String characteristic) {
    final mapData = <String, double>{};
    for (var doc in _docs!) {
      String key = doc.data()[characteristic].toLowerCase() ?? 'Non impostato';
      key = key[0].toUpperCase() + key.substring(1);
      mapData[key] = (mapData[key] ?? 0) + 1;
    }
    return mapData;
  }

}