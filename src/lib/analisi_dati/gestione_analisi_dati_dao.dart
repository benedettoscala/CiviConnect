import 'package:civiconnect/utils/report_status_priority.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

/// Data Access Object (DAO) for managing data analysis.
/// The DAO is used to retrieve data from the database
/// to be used in the data analysis for the municipality.
class DataAnalysisManagementDAO {

  /// The Firestore instance.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// The HeatMap data retrieved from the database.
  /// Whe DAO is used to retrieve the data, the data is stored in this variable to cache it.
  List<WeightedLatLng>? _data;


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
    final querySnapshot = await _firestore.collection('reports').doc(city).collection('${city}_reports').get();
    final docs = querySnapshot.docs;

    // If no data is available, return null.
    if(docs.isEmpty){
      return null;
    }
    print(docs.first.data()['location']);
    // The data is stored in a list of WeightedLatLng objects.
    _data = docs.map((doc) { GeoPoint point;
      try {
        point = doc.data()['location'] ?? const GeoPoint(0, 0);
      } on Exception catch (e) {
        point = const GeoPoint(0, 0);
      }
      print(point.latitude);
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
        return const LatLng(40.773837, 14.7884);
      }
      final point = docs.first.data()['location'] ?? const GeoPoint(40.773837, 14.7884);
      return LatLng(point.latitude, point.longitude);
    });
  }

}