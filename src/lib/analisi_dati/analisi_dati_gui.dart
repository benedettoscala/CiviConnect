import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';

import 'gestione_analisi_dati_controller.dart';

/// Widget stateful for viewing and editing user profile data.
class DataAnalysisGUI extends StatefulWidget {
  /// The controller for managing data analysis.
  final DataAnalysisManagementController? _controller;

  /// Widget stateful for viewing and editing user profile data.
  DataAnalysisGUI({super.key, DataAnalysisManagementController? controller}) : _controller = controller ?? DataAnalysisManagementController();


  @override
  State<DataAnalysisGUI> createState() => _DataAnalysisState(_controller!);
}

class _DataAnalysisState extends State<DataAnalysisGUI> {
  final DataAnalysisManagementController _controller;
  bool _isExpandedHM = false;
  bool _isMapReady = false;
  bool _isErrorMap = false;
  String? _errorText;
  List<WeightedLatLng>? _dataHeatMap;
  LatLng? _cityCoordinates;

  _DataAnalysisState(DataAnalysisManagementController controller) : _controller = controller;

  @override
  void initState() {
    super.initState();
    _loadData();
    _waitForLoading();
  }

  Future<void> _loadData() async {
    _controller.dataHeatMap().then((data) {
      _loadCityCoordinates();

      if(data != null){
        setState(() {
          _dataHeatMap = data;
        });
      }
    });
  }

  Future<void> _loadCityCoordinates() async {
    final city = await _controller.retrieveCityCoordinates();

    setState(() {
      _cityCoordinates = city;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Analisi Dati - Report',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10,),
              const Text (
                'Benvenuto nell\'area di analisi e dati dei report inviati press il tuo comune.\n'
                    'In quest\'area sarà possibile visualizzare grafici che possono aiutarti nel comprendere come le segnalazioni sono distribuite secondo varie statistiche.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30,),
              const Column(
                  children: [
                    Text(
                      'HeatMap',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ]
              ),
              ExpansionPanelList(
                animationDuration: const Duration(milliseconds: 500),
                children: [
                  ExpansionPanel(
                    canTapOnHeader: true,
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: const Text('HeatMap'),
                        onTap: () {
                          setState(() {
                            _waitForLoading();
                            _isExpandedHM = !_isExpandedHM;
                          });
                        },
                      );
                    },
                    isExpanded: _isExpandedHM,
                    backgroundColor: _isExpandedHM ? Theme
                        .of(context)
                        .colorScheme
                        .inversePrimary
                        : Theme
                        .of(context)
                        .colorScheme
                        .primaryContainer,
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.8,
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.5,
                          child: FlutterMap(
                            options: MapOptions(
                              onMapReady: () => _waitForLoading(ready: true),
                              initialCenter: (_cityCoordinates != null) ?
                                LatLng(_cityCoordinates!.latitude, _cityCoordinates!.longitude)
                                  : const LatLng(40.755931, 14.808357)
                              ,
                              // Start from (Fisciano)
                              initialZoom: 13.0,
                            ),
                            children: [
                              (_isMapReady) ? TileLayer(
                                errorTileCallback: (tile, error, stack) =>
                                    _errorMap(error),
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                tileProvider: CancellableNetworkTileProvider(),
                              ) : _buildErrorMap(),
                              if (_dataHeatMap != null && _dataHeatMap!.isNotEmpty) HeatMapLayer(
                                heatMapDataSource: InMemoryHeatMapDataSource(
                                    data: _dataHeatMap!),
                                heatMapOptions: HeatMapOptions(
                                    gradient: HeatMapOptions.defaultGradient,
                                    radius: 50,
                                    layerOpacity: 0.8,
                                    minOpacity: 0.1
                                ),
                              )
                            ],
                          ),
                        ),// : _buildErrorMap(), // Print Error or loading map
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Refreshes the data displayed in the widget.
  Future<void> _refreshData() async {
    return Future<void>.value();
  }

  /// Waits for the map to be ready then sets the [_isMapReady] flag.
  void _waitForLoading({bool? ready = false}) {
    if (ready == true && !_isMapReady) {
      setState(() {
        _isMapReady = true; // La mappa è pronta
      });
    }
  }

  /// Callback for the error tile of the map.
  /// Sets the [_isErrorMap] flag and the [_errorText] message.
  ErrorTileCallBack? _errorMap(Object? error) {
    if (_isErrorMap) {
      return null;
    }
    setState(() {
      debugPrint('Error: $error');
      _isErrorMap = true;
      _errorText = error.toString();
    });
    return null;
  }


  /// Builds the error map widget.
  /// If the map is not ready, it shows a loading indicator.
  /// If the map is ready, it shows an error message if error occurred.
  Widget _buildErrorMap() {
    return (!_isErrorMap) ? Stack(
      children: [
        SizedBox(
          height: 200,
          width: MediaQuery
              .of(context)
              .size
              .width * 0.7,
          child: const Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedMapsRefresh,
              color: Colors.grey,
              size: 200,
            ),
          ),
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    ) : Center(
      child: Text(_errorText ?? 'Errore nella visualizzazione della mappa'),
    );
  }


}



