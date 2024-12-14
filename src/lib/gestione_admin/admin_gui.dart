import 'package:flutter/material.dart';
import 'package:civiconnect/gestione_admin/gestione_admin_controller.dart';

import '../user_management/login_utente_gui.dart';
import '../utils/snackbar_riscontro.dart';

/// The Admin Home Page widget.
/// This page allows the Admin to generate credentials for municipalities.
/// The Admin can search for a municipality and generate credentials for it.
/// The page also provides a logout button to log out the Admin.
/// The page uses the `AdminManagementController` to handle the business logic.
/// The page displays a list of municipalities that can be searched using an autocomplete field.
/// The Admin can select a municipality from the list and generate credentials for it.
/// The page also displays the generated email and password for the municipality.
/// The page shows an error message if the municipality is already present in the database.
/// The page shows a success message if the credentials are generated successfully.
/// The page uses the `showMessage` function to display messages.
/// The page uses the `showAdminPasswordAndMunicipalityEmailDialog` function to show a dialog for entering the Admin password and municipality email.
/// The page uses the `_onMunicipalitySelected` function to handle the selection of a municipality from the autocomplete list.
/// The page uses the `_generateCredentials` function to generate credentials for the selected municipality.
/// The page uses the `_loadMunicipalities` function to load the list of municipalities from a JSON file.
/// The page uses the `_controller` to interact with the `AdminManagementController`.
/// The page uses the `_textEditingControllerAutocomplete` to control the autocomplete text field.
/// The page uses the `_allMunicipalities` to store the list of municipalities.
/// The page uses the `_selectedMunicipality` to store the selected municipality.
/// The page uses the `_generatedEmail` and `_generatedPassword` to store the generated email and password.
/// The page uses the `_isMunicipalityExisting` to store whether the municipality is already present in the database.
/// The page uses the `_showAdminPasswordAndMunicipalityEmailDialog` function to show a dialog for entering the Admin password and municipality email.
class AdminHomePage extends StatefulWidget {
  /// Creates an Admin Home Page widget.
  const AdminHomePage({super.key});

  @override
  AdminHomePageState createState() => AdminHomePageState();
}

/// The state of the Admin Home Page widget.
/// This state manages the state of the Admin Home Page widget.
/// The state uses the `AdminManagementController` to handle the business logic.
class AdminHomePageState extends State<AdminHomePage> {
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
      builder: (context) {
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
      await _controller.generateCredentials(_selectedMunicipality!, adminPassword, comuneEmail);

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
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<Map<String, String>>.empty();
                        } else {
                          return _controller.filterMunicipalities(
                              _allMunicipalities, textEditingValue.text);
                        }
                      },
                      displayStringForOption: (comune) =>
                          comune['Comune']!,
                      fieldViewBuilder: (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
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
                      onSelected: (selectedComune) {
                        _onMunicipalitySelected(selectedComune);
                      },
                      optionsViewBuilder: (
                        context,
                        onSelected,
                        options,
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
                                itemBuilder: (context, index) {
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
