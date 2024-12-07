import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';

/// Widget stateful for viewing and editing user profile data.
class DataAnalysisGUI extends StatefulWidget {
  /// Widget stateful for viewing and editing user profile data.
  const DataAnalysisGUI({super.key});

  @override
  State<DataAnalysisGUI> createState() => _DataAnalysisState();
}

class _DataAnalysisState extends State<DataAnalysisGUI> {
  bool _isExpandedHM = false;
  bool _isMapReady = false;
  bool _isErrorMap = false;
  String? _errorText;

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
              const Text ('Benvenuto nell\'area di analisi e dati dei report inviati press il tuo comune.\n'
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
                        onTap: (){
                          setState(() {
                            _waitForLoading();
                            _isExpandedHM = !_isExpandedHM;
                          });
                        },
                      );
                    },
                    isExpanded: _isExpandedHM,
                    backgroundColor: _isExpandedHM? Theme.of(context).colorScheme.inversePrimary : Theme.of(context).colorScheme.primaryContainer,
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Mappa termica delle segnalazioni'),
                        (!_isMapReady) ? FlutterMap(
                          options: MapOptions(
                              onMapReady: () => _waitForLoading(ready: true),
                              initialCenter: const LatLng(48.8583736,2.2922926), // Centro iniziale (Fisciano)
                              initialZoom: 13.0,
                          ),
                          children: [
                            TileLayer(
                              errorTileCallback: (tile, error, stack) => _errorMap(error),
                              urlTemplate: 'https://tile.openstreetmap.org/{zoom}/{x}/{y}.png',
                              tileProvider: CancellableNetworkTileProvider(),
                            ),
                          ],
                          //If is still loading
                        ) : (!_isErrorMap) ? Stack(
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
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        ) : Center(
                          child: Text(_errorText ?? 'Errore nella visualizzazione della mappa'),
                        ),
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


  void _waitForLoading({bool? ready = false}) {
    if(ready == true) {
      setState(() {
        _isMapReady = true; // La mappa è pronta
      });
    }
  }

  ErrorTileCallBack? _errorMap(Object? error) {
        setState(() {
          print('Error: $error');
          _isErrorMap = true;
          _errorText = error.toString();
        });
        return null;
  }

}


