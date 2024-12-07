import 'package:civiconnect/home_page.dart';
import 'package:civiconnect/model/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:civiconnect/widgets/input_textfield_decoration.dart';
import 'package:civiconnect/gestione_segnalazione_cittadino/gestione_segnalazione_cittadino_controller.dart';

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
  final CitizenReportManagementController _controller = CitizenReportManagementController(
      redirectPage: const HomePage());

  late Category _categoria;
  String? _descrizione;
  String? _titolo;
  String? _citta;
  String? _selectedImage;
  late Map<String, String>? _indirizzo;
  late GeoPoint _location;
  List<String>? _indirizzoLista;
  List<String>? _badWords;

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
              _buildImageCard(),
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
          validator: FormBuilderValidators.compose(
            [
              FormBuilderValidators.required(),
              (value) => _checkBadWords(value),
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
          decoration: TextFieldInputDecoration(context, labelText: 'Indirizzo'),
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
            decoration:
                TextFieldInputDecoration(context, labelText: 'Descrizione'),
            maxLines: 3,
            validator: FormBuilderValidators.compose(
              [
                FormBuilderValidators.required(),
                (value) => _checkBadWords(value),
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

  Widget _buildSelectPhotoButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedImage = _controller.shuffleImages(); // Replace with actual image URL or logic to select an image
        });
      },
      child: const Text('Seleziona Foto'),
    );
  }

Widget _buildImageCard() {
  return Card(
    clipBehavior: Clip.antiAlias, // Ensure the image follows the card's border radius
    child: Column(
      children: [
        if (_selectedImage != null)
          Image.network(
            _selectedImage!,
            width: 450, // Set the desired width
            height: 325, // Set the desired height
            fit: BoxFit.cover, // Ensure the image covers the area
          )
        else
          const Text('Nessuna immagine selezionata'),
      ],
    ),
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

  Future<void> sendData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

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

  /// Validates the description field to check for bad words.
  String? _checkBadWords(String? value) {
    if(_badWords == null || value == null || value.isEmpty) {
      return null;
    }
    if (_controller.containsBadWords(value, _badWords!)) {
        return 'La descrizione contiene parole non consentite';
    }
    return null;
  }


}
