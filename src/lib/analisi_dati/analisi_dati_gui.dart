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
  DataAnalysisGUI({super.key, DataAnalysisManagementController? controller})
      : _controller = controller ?? DataAnalysisManagementController();

  @override
  State<DataAnalysisGUI> createState() => _DataAnalysisState(_controller!);
}

class _DataAnalysisState extends State<DataAnalysisGUI> {
  /// The controller for managing data analysis.
  final DataAnalysisManagementController _controller;

  /// Flag to check if the HeatMap Panel is expanded.
  bool _isExpandedHM = false;

  /// Flag to check if the Pie Chart Panel is expanded.
  bool _isExpandedPC = false;

  /// Flag to check if the map is ready.
  bool _isMapReady = false;

  /// Flag to check if an error occurred while loading the map.
  bool _isErrorMap = false;

  /// The error text message.
  String? _errorText;

  /// The data for the HeatMap.
  List<WeightedLatLng>? _dataHeatMap;

  /// The coordinates of the city.
  LatLng? _cityCoordinates;

  /// Widget stateful for viewing and editing user profile data.
  /// - [controller]: The controller for managing data analysis.
  _DataAnalysisState(DataAnalysisManagementController controller)
      : _controller = controller;

  /* Stateful Init methods */

  @override
  void initState() {
    super.initState();
    _loadData();
    _waitForLoading();
  }

  /// Loads the data for the HeatMap.
  /// The data is retrieved from the database.
  /// The city coordinates are also retrieved.
  /// The data is stored in the [_dataHeatMap] variable.
  /// The city coordinates are stored in the [_cityCoordinates] variable.
  Future<void> _loadData() async {
    _controller.dataHeatMap().then((data) {
      _loadCityCoordinates();

      if (data != null) {
        setState(() {
          _dataHeatMap = data;
        });
      }
    });
  }

  /// Loads the coordinates of the city.
  Future<void> _loadCityCoordinates() async {
    final city = await _controller.retrieveCityCoordinates();

    setState(() {
      _cityCoordinates = city;
    });
  }

  /* Widget build */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Card(
            margin: const EdgeInsets.all(10),
            color: Colors.white,
            elevation: 5.0,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Analisi Dati - Report',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Benvenuto nell\'area di analisi dati dei report inviati presso il tuo comune.\n\n'
                      'In questa sezione troverai strumenti utili per analizzare e comprendere la distribuzione delle segnalazioni attraverso diverse statistiche.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ExpansionTile(
                  title: const Text('HeatMap'),
                  iconColor: Colors.black,
                  collapsedIconColor: Colors.black,
                  backgroundColor: Colors.white70,
                  children: [
                    _buildHeatMap()
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ExpansionTile(
                  title: const Text('Grafici'),
                  iconColor: Colors.black,
                  collapsedIconColor: Colors.black,
                  backgroundColor: Colors.white70,
                  children: [
                    _buildPieChart()
                  ],
                ),
              ],
            ),
          )
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
    return (!_isErrorMap)
        ? Stack(
            children: [
              SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width * 0.7,
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
          )
        :
    Center(
      child: Text(_errorText ?? 'Errore nella visualizzazione della mappa'),
    );
  }

  /// Builds the HeatMap Expansion Panel.
  /// If the data is not available, it shows a loading indicator.
  /// If the data is available, it shows the HeatMap.
  Widget _buildHeatMap() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            child: (_cityCoordinates != null)
                ? FlutterMap(
                  options: MapOptions(
                    onMapReady: () => _waitForLoading(ready: true),
                    initialCenter:
                            _cityCoordinates !,
                    // Start from (Fisciano)
                    initialZoom: 13.0,
                  ),
                  children: [
                    (_isMapReady)
                        ? TileLayer(
                            errorTileCallback: (tile, error, stack) =>
                                _errorMap(error),
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            tileProvider: CancellableNetworkTileProvider(),
                          )
                        : _buildErrorMap(),
                    if (_dataHeatMap != null && _dataHeatMap!.isNotEmpty)
                      HeatMapLayer(
                        heatMapDataSource:
                            InMemoryHeatMapDataSource(data: _dataHeatMap!),
                        heatMapOptions: HeatMapOptions(
                            gradient: HeatMapOptions.defaultGradient,
                            radius: 50,
                            layerOpacity: 0.8,
                            minOpacity: 0.1
                        ),
                      ),
                  ],
                ) : _buildErrorMap(),
          ), // : _buildErrorMap(), // Print Error or loading map
        ],
      );
  }


  /// Builds the Pie Chart Expansion Panel.
  ///
  ExpansionTile _buildPieChart() {
    return ExpansionTile(
      title: const Text('Grafici'),
      subtitle: const Text('Visualizza i grafici e le statistiche'),
      trailing: (_isExpandedPC) ? const Icon(Icons.pie_chart) : const Icon(Icons.pie_chart_outline_outlined),
      onExpansionChanged: (isExpanded) {
        setState(() {
          if(_pieData == null) {
            _controller.retrieveDataForAnalysis(DataPartition.category)
                .then((data) {
              _pieData = data;
            });
          }
          _isExpandedPC = isExpanded;
        });
      },
      backgroundColor: _isExpandedPC
          ? Theme.of(context).colorScheme.inversePrimary
          : Theme.of(context).colorScheme.primaryContainer,
        children: [
          const DropdownMenu(
            label: Text('Seleziona la partizione dei dati'),
            dropdownMenuEntries: [
              DropdownMenuEntry(
                  label: 'Status', value: DataPartition.status),
              DropdownMenuEntry(
                  label: 'Category', value: DataPartition.category),
              DropdownMenuEntry(
                  label: 'Priority', value: DataPartition.priority),
            ],
          ),
          const Text('Pie Chart'),
          (_pieData != null && _pieData!.isNotEmpty)
              ? PieChart(
                  dataMap: _pieData ?? {},
                  animationDuration: const Duration(milliseconds: 800),
            chartLegendSpacing: 32,
            chartRadius: MediaQuery.of(context).size.width / 2.7,
            colorList: const [
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
              Colors.pink,
              Colors.teal,
              Colors.brown,
              Colors.cyan,
            ],
            initialAngleInDegree: 0,
            chartType: ChartType.disc,
        )
            : const CircularProgressIndicator(),
      ]
    );
  }
}
