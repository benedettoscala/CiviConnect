import 'package:civiconnect/model/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:civiconnect/widgets/input_textfield_decoration.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

import 'gestione_segnalazione_cittadino_controller.dart';

class InserimentoSegnalazioneGUI extends StatefulWidget {
  const InserimentoSegnalazioneGUI({super.key});

  @override
  State<InserimentoSegnalazioneGUI> createState() =>
      _InserimentoSegnalazioneGUIState();
}

class _InserimentoSegnalazioneGUIState
    extends State<InserimentoSegnalazioneGUI> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _indirizzoController = TextEditingController();
  final TextEditingController _cittaController = TextEditingController();
  late CitizenReportManagementController _controller;

  late Category _categoria;
  String? _descrizione;
  String? _titolo;
  String? _citta;
  late Map<String, String>? _indirizzo;
  late GeoPoint _location;
  List<String>? _indirizzoLista;

  @override
  void initState() {
    super.initState();
    _indirizzoController.text = 'Caricamento Posizione...';
    _cittaController.text = 'Caricamento Città...';
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    _indirizzoLista = await getLocation();
    setState(() {
      _indirizzoController.text =
          '${_indirizzoLista!.elementAt(1)} ${_indirizzoLista!.elementAt(2)}'; //strada civico
      _cittaController.text = _indirizzoLista!.elementAt(0);
    });
  }

  @override
  void dispose() {
    _indirizzoController.dispose();
    super.dispose();
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
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildCategoryField(),
              const SizedBox(height: 20),
              _buildCityField(),
              const SizedBox(height: 20),
              _buildAddressField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 20),
              _buildSelectPhotoButton(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Titolo', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
            decoration: TextFieldInputDecoration(context, labelText: 'Titolo'),
            validator: FormBuilderValidators.required(),
            onChanged: (value) => {
                  setState(() {
                    _titolo = value;
                  }),
                }),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<Category>(
          decoration: TextFieldInputDecoration(context, labelText: 'Categoria'),
          items: Category.values.map((category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Text(category.name()),
            );
          }).toList(),
          onChanged: (value) => {
            setState(() {
              _categoria = value!;
            }),
          },
          validator: FormBuilderValidators.required(),
        ),
      ],
    );
  }

  Widget _buildCityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Città', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
            controller: _cittaController,
            decoration: TextFieldInputDecoration(context, labelText: 'Città'),
            validator: FormBuilderValidators.required(),
            onSaved: (value) => {
                  setState(() {
                    _citta = value;
                  }),
                }),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Indirizzo', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _indirizzoController,
          decoration: TextFieldInputDecoration(context, labelText: 'Indirizzo'),
          validator: FormBuilderValidators.required(),
          onSaved: (value) => {
            setState(() {
              _indirizzo = {
                'street': value!
                    .split(' ')
                    .sublist(0, value.split(' ').length - 1)
                    .join(' '),
                'number': value.split(' ').last
              };
            })
          },
        )
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Descrizione',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
            decoration:
                TextFieldInputDecoration(context, labelText: 'Descrizione'),
            maxLines: 3,
            validator: FormBuilderValidators.required(),
            onChanged: (value) => {
                  setState(() {
                    _descrizione = value;
                  }),
                }),
      ],
    );
  }

  Widget _buildSelectPhotoButton() {
    return ElevatedButton(
      onPressed: () {},
      child: const Text('Seleziona Foto'),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        sendData();
      },
      child: const Text('Invia Segnalazione'),
    );
  }

  Future<List<String>> getLocation() async {
    final stopwatch = Stopwatch()..start();
    loc.Location location = loc.Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        stopwatch.stop();
        print('Tempo impiegato: ${stopwatch.elapsedMilliseconds} ms');
        return [
          'Servizio non abilitato.',
          'Servizio non abilitato.',
          'Servizio non abilitato.'
        ];
      }
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        stopwatch.stop();
        print('Tempo impiegato: ${stopwatch.elapsedMilliseconds} ms');
        return ['Permessi negati.', 'Permessi negati.', 'Permessi negati.'];
      }
    }

    if (permissionGranted == loc.PermissionStatus.deniedForever) {
      stopwatch.stop();
      print('Tempo impiegato: ${stopwatch.elapsedMilliseconds} ms');
      return [
        'Permessi negati permanentemente.',
        'Permessi negati permanentemente.',
        'Permessi negati permanentemente.'
      ];
    }

    loc.LocationData locationData = await location.getLocation();
    _location = GeoPoint(
        locationData.latitude!, locationData.longitude!); //setting posizione
    List<Placemark> placemarks = await placemarkFromCoordinates(
        locationData.latitude!, locationData.longitude!);
    stopwatch.stop();
    print('Tempo impiegato: ${stopwatch.elapsedMilliseconds} ms');
    return [
      placemarks[0].locality ?? "Località non disponibile",
      placemarks[0].street ?? "Strada non disponibile",
      placemarks[0].name ?? "Nome non disponibile"
    ];
  }

  Future<void> sendData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _controller = CitizenReportManagementController(
          redirectPage: const InserimentoSegnalazioneGUI());

      await _controller.addReport(
        context,
        citta: _citta!,
        titolo: _titolo!,
        descrizione: _descrizione!,
        categoria: _categoria,
        location: _location, // Replace with actual location data
        indirizzo: _indirizzo,
      );
    }
  }
}
