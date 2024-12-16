import 'dart:io';

import 'package:civiconnect/gestione_segnalazione_cittadino/gestione_permessi_failed.dart';

//import 'package:civiconnect/widgets/input_textfield_decoration.dart';
import 'package:civiconnect/gestione_segnalazione_cittadino/gestione_segnalazione_cittadino_controller.dart';
import 'package:civiconnect/home_page.dart';
import 'package:civiconnect/model/report_model.dart';
import 'package:civiconnect/utils/snackbar_riscontro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';

import '../theme.dart';

/// A widget that provides a GUI for inserting a citizen report.
class InserimentoSegnalazioneGUI extends StatefulWidget {
  /// Controller for managing citizen reports if not provided a new default instance is created.
  final CitizenReportManagementController controller;

  /// Image picker for selecting images if not provided a new default instance is created.
  final ImagePicker imagePicker;

  /// Creates an instance of InserimentoSegnalazioneGUI.
  InserimentoSegnalazioneGUI(
      {super.key, CitizenReportManagementController? controller, ImagePicker? imagePicker})
      : controller = controller ??
            CitizenReportManagementController(redirectPage: const HomePage()), imagePicker = imagePicker ?? ImagePicker();

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
  late final CitizenReportManagementController _controller;
  late final ImagePicker _imagePicker;

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

  final _titoloKey = const Key('Titolo');
  final _categoriaKey = const Key('Categoria');
  final _cittaKey = const Key('Città');
  final _indirizzoKey = const Key('Indirizzo');
  final _descrizioneKey = const Key('Descrizione');
  final _photoKey = const Key('Foto');
  final _photoSubmitKey = const Key('FotoSubmit');
  final _submitKey = const Key('Invia');
  final _list = const Key('InserimentoSegnalazione');
  bool _isInItaly = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _imagePicker = widget.imagePicker;
    _indirizzoController.text = 'Caricamento Posizione...';
    _cittaController.text = 'Caricamento Città...';
    _fetchLocation();
    _controller.getBadWords().then((value) => _badWords = value);
  }

  Future<void> _fetchLocation() async {
    _location = (await _controller.getCoordinates(context))!;
    _indirizzoLista = await _controller.getLocation(_location);
    setState(() {
      if (_indirizzoLista!.elementAt(3) != 'Italy' &&
          _indirizzoLista!.elementAt(3) != 'Italia') {
        showMessage(context, isError: true, message: 'Non sei in Italia');
        _isInItaly = false;
      }
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
              child: SingleChildScrollView(
                key: _list,
                child: Column(
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
          key: _titoloKey,
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
      key: _categoriaKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<Category>(
          //decoration: TextFieldInputDecoration(context, labelText: 'Categoria'),
          items: Category.values.map((category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) => {
            setState(() {
              _categoria = value!;
            }),
          },
          validator: FormBuilderValidators.compose(
            [
              FormBuilderValidators.required(
                  errorText: 'Il campo è obbligatorio'),
              (value) {
                if (value != Category.waste &&
                    value != Category.maintenance &&
                    value != Category.roadDamage &&
                    value != Category.lighting) {
                  return 'Categoria non valida';
                }
                return null;
              },
            ],
          ),
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
            key: _cittaKey,
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
          key: _indirizzoKey,
          controller: _indirizzoController,
          //decoration: TextFieldInputDecoration(context, labelText: 'Indirizzo'),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
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
            }
            ),
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
          key: _descrizioneKey,
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
              key: _photoKey,
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
        key: _photoSubmitKey,
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
      key: _submitKey,
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
    if (_formKey.currentState!.validate() && _isInItaly) {
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
    } else if(!_isInItaly){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Non sei in Italia'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<bool> sendData() async {
    bool result = false;
    if (_formKey.currentState!.validate() && _isInItaly) {
      _formKey.currentState!.save();

      result = await _controller.addReport(
        context,
        citta: _citta!,
        titolo: _titolo!,
        descrizione: _descrizione!,
        categoria: _categoria,
        location: _location,
        // Replace with actual location data
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
      return 'Il campo contiene parole non consentite';
    }
    return null;
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.camera);
      if (pickedFile != null && pickedFile.path.toLowerCase().endsWith('.jpg')) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      } else {
        showMessage(context, isError: true, message: 'Estensione immagine non valida');
      }
    } catch (e) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => const PermissionPage(
                  redirectPage: HomePage(),
                  error: 'Abilita i permessi della fotocamera',
                  icon: Icons.camera_alt,
                )),
      );
    }
  }
}
