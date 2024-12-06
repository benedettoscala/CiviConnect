import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10,),
              const Text ('Benvenuto nell\'area di analisi e dati dei report inviati press il tuo comune.\n'
                  'In quest\'area sarà possibile visualizzare grafici che possono aiutarti nel comprendere come le segnalazioni sono distribuite secondo varie statistiche.',
                style: TextStyle(
                  fontSize: 15,
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
                        (_isMapReady) ? FlutterMap(
                          options: const MapOptions(
                              initialCenter: LatLng(40.7736, 14.7925), // Centro iniziale (Fisciano)
                              initialZoom: 13.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{zoom}/{x}/{y}.png',
                              tileProvider: NetworkTileProvider(),
                            ),
                          ],
                        ) : const CircularProgressIndicator(),
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


  Future<void> _waitForLoading() async {
    // Simula un caricamento (per es., inizializzazione delle tiles)
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isMapReady = true; // La mappa è pronta
    });
  }



}


