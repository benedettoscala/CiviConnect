import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:civiconnect/widgets/input_textfield_decoration.dart';
import 'package:location/location.dart'as loc;
import 'package:geocoding/geocoding.dart';

class InserimentoSegnalazioneGUI extends StatefulWidget {
  const InserimentoSegnalazioneGUI({super.key});


  @override
  State<InserimentoSegnalazioneGUI> createState() => _InserimentoSegnalazioneGUIState();
}

class _InserimentoSegnalazioneGUIState extends State<InserimentoSegnalazioneGUI> {
  final _formKey = GlobalKey<FormState>();
 /* String? _categoria;
  String? _indirizzo;
  String? _descrizione;
  String? _titolo;
*/
  //XFile? _image;
  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserisci Segnalazione'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Titolo', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                decoration: TextFieldInputDecoration(
                    context, labelText: 'Titolo'),
                validator: FormBuilderValidators.required(),
                onSaved: (value) {
                  //_titolo = value;
                },
              ),
              const SizedBox(height: 16),
              const Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: TextFieldInputDecoration(
                    context, labelText: 'Categoria'),
                items: <String>['Categoria 1', 'Categoria 2', 'Categoria 3']
                    .map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    //_categoria = newValue;
                  });
                },
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              const Text('Indirizzo', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                decoration: TextFieldInputDecoration(
                    context, labelText: 'Indirizzo'),
                validator: FormBuilderValidators.required(),
                onSaved: (value) {
                 // _indirizzo = value;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                  'Descrizione', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                decoration: TextFieldInputDecoration(
                    context, labelText: 'Descrizione'),
                maxLines: 3,
                validator: FormBuilderValidators.required(),
                onSaved: (value) {
                  //_descrizione = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Seleziona Foto'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Handle form submission
                  }
                },
                child: const Text('Invia Segnalazione'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getLocation() async {

    //FUNZIONE CHE STAMPA LA LOCATION
    loc.Location location = loc.Location();

    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    // Controlla se il servizio di localizzazione è abilitato
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print('Servizio di localizzazione non abilitato.');
        return;
      }
    }

    // Controlla i permessi
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == loc.PermissionStatus.denied) {
        print('Permessi negati.');
        return;
      }
    }

    if (_permissionGranted == loc.PermissionStatus.deniedForever) {
      print(
          'Permessi negati permanentemente. Apri le impostazioni per abilitarli.');
      return;
    }

    // Ottieni la posizione prima prendo le coordinate (lat e long) e poi stampo solamente la "street" (via
    // TO-DO : se c'è qualcos altro di utile da stampare
    //         Dobbiamo gestire i casi in cui non ci sono i permessi per la posizione
    //      magari possiamo far inserire l indirizzo manualmente ???
    loc.LocationData _locationData = await location.getLocation();
    print('Latitudine: ${_locationData.latitude}, Longitudine: ${_locationData
        .longitude}');
    List<Placemark> placemarks = await placemarkFromCoordinates(
        _locationData.latitude!, _locationData.longitude!);

    print(placemarks[0].street);
  }
}
