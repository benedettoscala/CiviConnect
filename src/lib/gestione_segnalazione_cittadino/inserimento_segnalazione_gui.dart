import 'dart:io';

import 'package:civiconnect/gestione_segnalazione_cittadino/gestione_location_failed.dart';
import 'package:civiconnect/home_page.dart';
import 'package:civiconnect/model/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
//import 'package:civiconnect/widgets/input_textfield_decoration.dart';
import 'package:civiconnect/gestione_segnalazione_cittadino/gestione_segnalazione_cittadino_controller.dart';
import 'package:image_picker/image_picker.dart';

import '../theme.dart';

/// A widget that provides a GUI for inserting a citizen report.
class InserimentoSegnalazioneGUI extends StatefulWidget {
  /// Creates an instance of InserimentoSegnalazioneGUI.
  const InserimentoSegnalazioneGUI({super.key});

  @override
  State<InserimentoSegnalazioneGUI> createState() =>
      _InserimentoSegnalazioneGUIState();
}

class _InserimentoSegnalazioneGUIState
    extends State<InserimentoSegnalazioneGUI> {
  final theme = ThemeManager().customTheme;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _indirizzoController = TextEditingController();
  final TextEditingController _cittaController = TextEditingController();
  final CitizenReportManagementController _controller =
      CitizenReportManagementController(redirectPage: const HomePage());

  late Category _categoria;
  String? _descrizione;
  String? _titolo;
  String? _citta;
  File? _selectedImage;
  late Map<String, String>? _indirizzo;
  late GeoPoint _location;
  List<String>? _indirizzoLista;
  List<String>? _badWords;
  late bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _indirizzoController.text = 'Caricamento Posizione...';
    _cittaController.text = 'Caricamento Città...';
    _fetchLocation();
    _controller.getBadWords().then((value) => _badWords = value);
  }

  Future<void> _fetchLocation() async {
    _location = (await getCoordinates(context))!;
    _indirizzoLista = await getLocation(_location);
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
        title: const Text(
          'Inserimento Segnalazione',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
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
                  _buildImageCard(),
                  const SizedBox(height: 20),
                  _buildSelectPhotoButton(),
                  const SizedBox(height: 20),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                  _buildFooter(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
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
          //decoration: TextFieldInputDecoration(context, labelText: 'Titolo'),
          validator: FormBuilderValidators.compose(
            [
              FormBuilderValidators.required(
                  errorText: 'Il campo è obbligatorio'),
              FormBuilderValidators.maxLength(255,
                  errorText: 'Massimo 255 caratteri'),
              (value) {
                final error = _checkBadWords(value);
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                  return error;
                }
                return null;
              },
            ],
          ),
          onChanged: (value) => {
            setState(
              () {
                _titolo = value;
              },
            ),
          },
        ),
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
          //decoration: TextFieldInputDecoration(context, labelText: 'Categoria'),
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
            //decoration: TextFieldInputDecoration(context, labelText: 'Città'),
            validator: FormBuilderValidators.required(),
            enabled: false,
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
          //decoration: TextFieldInputDecoration(context, labelText: 'Indirizzo'),
          validator: FormBuilderValidators.required(),
          enabled: false,
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
          //decoration:TextFieldInputDecoration(context, labelText: 'Descrizione'),
          maxLines: 3,
          validator: FormBuilderValidators.compose(
            [
              FormBuilderValidators.required(
                  errorText: 'Il campo è obbligatorio'),
              FormBuilderValidators.maxLength(1023,
                  errorText: 'Massimo 1023 caratteri'),
              (value) {
                final error = _checkBadWords(value);
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                  return error;
                }
                return null;
              },
            ],
          ),
          onChanged: (value) => {
            setState(() {
              _descrizione = value;
            }),
          },
        ),
      ],
    );
  }

  Widget _buildImageCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      child: _selectedImage != null
          ? Image.file(
              _selectedImage!,
              width: 450, // Set the desired width
              height: 325, // Set the desired height
              fit: BoxFit.cover, // Ensure the image covers the area
            )
          : Container(
              height: 325,
              color: Colors.grey.shade200,
              child: const Center(
                child: Text(
                  'Nessuna immagine selezionata',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
    );
  }

  Widget _buildSelectPhotoButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _pickImageFromCamera,
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text('Scatta Foto',
            style: TextStyle(fontSize: 16, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          padding: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
        child: ElevatedButton.icon(
      onPressed: _isLoading ? null : _onSubmit,
      icon: const Icon(Icons.send, color: Colors.white),
      label: const Text('Invia Segnalazione',
          style: TextStyle(fontSize: 16, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.buttonTheme.colorScheme!.primary,
        padding: const EdgeInsets.all(14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ));
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Icon(Icons.report_problem, size: 48, color: Colors.red),
        SizedBox(height: 12),
        Text(
          'Inserisci una nuova segnalazione',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Compila i campi sottostanti per inviare una nuova segnalazione.',
          style: TextStyle(fontSize: 16, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Divider(
          thickness: 1,
          height: 10,
          color: Color.fromRGBO(0, 69, 118, 1),
        ),
        SizedBox(height: 8),
        Text(
          'Grazie per il tuo contributo!',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_selectedImage != null) {
        setState(() => _isLoading = true);
        bool result = await sendData();
        setState(() => _isLoading = false);

        final message = result
            ? 'Invio effettuato con successo!'
            : 'Errore durante l\'invio della segnalazione';
        final color = result ? Colors.green : Colors.red;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: color),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Devi scattare un\'immagine'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<bool> sendData() async {
    bool result = false;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      result = await _controller.addReport(
        context,
        citta: _citta!,
        titolo: _titolo!,
        descrizione: _descrizione!,
        categoria: _categoria,
        location: _location, // Replace with actual location data
        indirizzo: _indirizzo,
        photo: _selectedImage,
      );
    }
    return result;
  }

  /// Validates the description field to check for bad words.
  String? _checkBadWords(String? value) {
    if (_badWords == null || value == null || value.isEmpty) {
      return null;
    }
    if (_controller.containsBadWords(value, _badWords!)) {
      return 'La descrizione contiene parole non consentite';
    }
    return null;
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => const PermissionPage(
                  redirectPage: HomePage(), error:'Abilita i permessi della fotocamera', icon: Icons.camera_alt,
                )),
      );
    }
  }
}