import 'package:flutter/material.dart';
import 'package:civiconnect/gestione_admin/gestione_admin_controller.dart';

import '../user_management/login_utente_gui.dart';
import '../utils/snackbar_riscontro.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AdminManagementController _controller = AdminManagementController();
  // Controller fo searched field
  TextEditingController? _textEditingControllerAutocomplete;
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

  /// Load the list of municipalities from the JSON file.
  void _loadMunicipalities() async {
    List<Map<String, String>> municipalities =
        await _controller.loadMunicipalities();
    setState(() {
      _allMunicipalities = municipalities;
    });
  }

  /// Handle the selection of a municipality from the autocomplete list.
  Future<void> _onMunicipalitySelected(
      Map<String, String> selectedMunicipality) async {
    bool exists = await _controller
        .municipalityExistsInDatabase(selectedMunicipality['Comune']!);
    setState(() {
      _selectedMunicipality = selectedMunicipality;
      _isMunicipalityExisting = exists;
    });
    if (exists) {
      showMessage(context,
          isError: true, message: 'Comune già presente nel database');
    }
  }

  /// Show a dialog to enter the Admin password and municipality email.
  Future<Map<String, String>?> _showAdminPasswordAndMunicipalityEmailDialog(
      BuildContext context) async {
    String enteredPassword = '';
    String enteredEmail = '';
    String? passwordErrorMessage;
    String? emailErrorMessage;

    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isPasswordValid =
                _controller.validatePassword(enteredPassword) == null;
            bool isEmailValid = _controller.validateEmail(enteredEmail) == null;
            return AlertDialog(
              title: const Center(
                  child: Text(
                      'Inserisci l\'email del comune e la password Admin')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        enteredEmail = value;
                        emailErrorMessage = _controller.validateEmail(value);
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Email del Comune',
                    ),
                  ),
                  if (emailErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        emailErrorMessage!,
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                  TextField(
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        enteredPassword = value;
                        passwordErrorMessage =
                            _controller.validatePassword(value);
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Password Admin',
                    ),
                  ),
                  if (passwordErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        passwordErrorMessage!,
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                ],
              ),
              actions: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(null); // No data if canceled
                    },
                    child: const Text('Annulla'),
                  ),
                  TextButton(
                    onPressed: isPasswordValid && isEmailValid
                        ? () {
                            Navigator.of(context).pop({
                              'password': enteredPassword,
                              'email': enteredEmail,
                            }); // Return the password and email
                          }
                        : null, // Disable the button if the password or email is invalid
                    child: const Text('Conferma'),
                  ),
                ])
              ],
            );
          },
        );
      },
    );
  }

  /// Generate credentials for the selected municipality.
  void _generateCredentials(String adminPassword, String comuneEmail) async {
    try {
      Map<String, String> credentials = await _controller.generateCredentials(
          _selectedMunicipality!, adminPassword, comuneEmail);

      setState(() {
        _generatedEmail = credentials['email'];
        _generatedPassword = credentials['password'];
      });

      _textEditingControllerAutocomplete!.clear();

      // Show a snackbar with the success message
      showMessage(context, message: 'Credenziali generate con successo');
    } catch (e) {
      // Show a snackbar with the error message
      showMessage(context, isError: true, message: '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bentornato, Admin'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await _controller.logOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginUtenteGUI()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Autocomplete<Map<String, String>>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<Map<String, String>>.empty();
                        } else {
                          return _controller.filterMunicipalities(
                              _allMunicipalities, textEditingValue.text);
                        }
                      },
                      displayStringForOption: (Map<String, String> comune) =>
                          comune['Comune']!,
                      fieldViewBuilder: (
                        BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        _textEditingControllerAutocomplete =
                            textEditingController;

                        // Listener for the text field
                        textEditingController.addListener(() {
                          if (textEditingController.text.isEmpty &&
                              _selectedMunicipality != null) {
                            setState(() {
                              _selectedMunicipality = null;
                              _isMunicipalityExisting = false;
                            });
                          }
                        });
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Cerca Comune',
                            suffixIcon: textEditingController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      textEditingController.clear();
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                      onSelected: (Map<String, String> selectedComune) {
                        _onMunicipalitySelected(selectedComune);
                      },
                      optionsViewBuilder: (
                        BuildContext context,
                        AutocompleteOnSelected<Map<String, String>> onSelected,
                        Iterable<Map<String, String>> options,
                      ) {
                        final List<Map<String, String>> optionsList =
                            options.toList();
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 32,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: optionsList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Map<String, String> option =
                                      optionsList[index];
                                  bool isTop7 = index < 7;

                                  return Container(
                                    color: isTop7
                                        ? Colors.grey[200]
                                        : Colors.white,
                                    child: ListTile(
                                      title: Text(option['Comune']!),
                                      subtitle: Text(
                                          'Provincia: ${option['Provincia']}'),
                                      onTap: () {
                                        onSelected(option);
                                      },
                                    ),
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
                                  onPressed: () async {
                                    if (_selectedMunicipality == null ||
                                        _selectedMunicipality!.isEmpty) {
                                      showMessage(context,
                                          isError: true,
                                          message: 'Selezionare un comune');
                                      return;
                                    }
                                    // Show the dialog to enter the Admin password
                                    final result =
                                        await _showAdminPasswordAndMunicipalityEmailDialog(
                                            context);

                                    // Generate credentials if the Admin password and email are not null
                                    if (result != null &&
                                        result['password']!.isNotEmpty &&
                                        result['email']!.isNotEmpty) {
                                      _generateCredentials(result['password']!,
                                          result['email']!);
                                    }
                                  },
                                  child: const Text('Genera Credenziali'),
                                ),
                        ],
                      ),
                    // TODO: Remoove this after email sent is handled
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
            ),
          ],
        ),
      ),
    );
  }
}
