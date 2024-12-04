import 'package:flutter/material.dart';
import 'package:civiconnect/gestione_admin/gestione_admin_controller.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AdminManagementController _controller = AdminManagementController(redirectPage: const AdminHomePage());
  List<Map<String, String>> _allMunicipalities = [];
  Map<String, String>? _selectedMunicipality;
  String? _generatedEmail;
  String? _generatedPassword;
  bool _isMunicipalityExisting = false;

  @override
  void initState() {
    super.initState();
    _loadMunicipalities();
  }

  void _loadMunicipalities() async {
    List<Map<String, String>> municipalities = await _controller.loadMunicipalities();
    setState(() {
      _allMunicipalities = municipalities;
    });
  }

  Future<void> _onMunicipalitySelected(Map<String, String> selectedMunicipality) async {
    bool exists = await _controller.municipalityExistsInDatabase(selectedMunicipality['Comune']!);
    setState(() {
      _selectedMunicipality = selectedMunicipality;
      _isMunicipalityExisting = exists;
    });
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comune già presente nel database')),
      );
    }
  }

  void _generateCredentials() async {
    try {
      Map<String, String> credentials =
      await _controller.generateCredentials(_selectedMunicipality!);

      setState(() {
        _generatedEmail = credentials['email'];
        _generatedPassword = credentials['password'];
      });

      // Show a snackbar with results
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenziali generate con successo')),
      );
    } catch (e) {
      // Error handling
      print('Errore nella generazione delle credenziali: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bentornato Supremo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Autocomplete<Map<String, String>>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Map<String, String>>.empty();
                } else {
                  return _allMunicipalities.where((Map<String, String> comune) {
                    return comune['Comune']!.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  }).take(7);
                }
              },
              displayStringForOption: (Map<String, String> comune) => comune['Comune']!,
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Cerca Comune',
                  ),
                );
              },
              onSelected: (Map<String, String> selectedComune) {
                _onMunicipalitySelected(selectedComune);
              },
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Map<String, String>> onSelected, Iterable<Map<String, String>> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 32,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Map<String, String> option = options.elementAt(index);
                          return ListTile(
                            title: Text(option['Comune']!),
                            subtitle: Text('Provincia: ${option['Provincia']}'),
                            onTap: () {
                              onSelected(option);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_selectedMunicipality != null)
              Column(
                children: [
                  _isMunicipalityExisting
                      ? const Text(
                    'Comune già presente nel database',
                    style: TextStyle(color: Colors.red),
                  )
                      : ElevatedButton(
                    onPressed: _generateCredentials,
                    child: const Text('Genera Credenziali'),
                  ),
                ],
              ),
            if (_generatedEmail != null && _generatedPassword != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: $_generatedEmail'),
                  Text('Password: $_generatedPassword'),
                ],
              ),
          ],

        ),
      ),
    );
  }
}