import 'dart:convert';

import 'package:civiconnect/theme.dart';
import 'package:civiconnect/user_management/user_management_controller.dart';
//import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../home_page.dart';
//import '../main.dart';
import '../widgets/logo_widget.dart';
import 'login_utente_gui.dart';

/// Registration page for new users.
class RegistrazioneUtenteGui extends StatefulWidget {
  /// Registration page for new users.
  const RegistrazioneUtenteGui({super.key});

  @override
  State<RegistrazioneUtenteGui> createState() => _RegistrazioneUtenteGuiState();
}

class _RegistrazioneUtenteGuiState extends State<RegistrazioneUtenteGui> {
  String email = '';
  String password = '';
  String firstName = '';
  String lastName = '';
  String city = '';
  String cap = '';
  Map<String, String> address = {
    'number': '',
    'street': '',
  };
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager().seedColor,
      body: _RegistrationFormWidget(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo
                const LogoWidget(),
                // Form
                FormBuilder(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Benvenuto',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.email(),
                          FormBuilderValidators.required(),
                        ]),
                        name: 'email',
                        decoration: _inputDecoration(context, 'Email').copyWith(
                          errorStyle: TextStyle(color: Colors.redAccent),
                        ),
                        onChanged: (value) {
                          setState(() {
                            email = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.password(
                              minLength: 8, maxLength: 4096),
                          FormBuilderValidators.required(),
                        ]),
                        obscureText: true,
                        name: 'password',
                        decoration: _inputDecoration(context, 'Password'),
                        onChanged: (value) {
                          setState(() {
                            password = value!;
                          });
                        },
                      ),
                      SizedBox(
                        height: 60,
                        child: Divider(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      FormBuilderTextField(
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: 'Il nome è obbligatorio'),
                          FormBuilderValidators.match(RegExp(r'^[a-zA-Z]+$'),
                              errorText:
                                  'Il nome può contenere solo caratteri alfabetici'),
                          FormBuilderValidators.maxLength(255,
                              errorText:
                                  'Il nome non può superare i 255 caratteri'),
                        ]),
                        name: 'firstName',
                        decoration: _inputDecoration(context, 'Nome').copyWith(
                          errorStyle: TextStyle(color: Colors.redAccent),
                        ),
                        onChanged: (value) {
                          setState(() {
                            firstName = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: 'Il cognome è obbligatorio'),
                          FormBuilderValidators.match(RegExp(r'^[a-zA-Z]+$'),
                              errorText:
                                  'Il cognome può contenere solo caratteri alfabetici'),
                          FormBuilderValidators.maxLength(255,
                              errorText:
                                  'Il cognome non può superare i 255 caratteri'),
                        ]),
                        name: 'lastName',
                        decoration:
                            _inputDecoration(context, 'Cognome').copyWith(
                          errorStyle: TextStyle(color: Colors.redAccent),
                        ),
                        onChanged: (value) {
                          setState(() {
                            lastName = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: 'La città è obbligatoria'),
                          FormBuilderValidators.match(RegExp(r'^[a-zA-Z\s]+$'),
                              errorText:
                                  'La città può contenere solo caratteri alfabetici e spazi'),
                          FormBuilderValidators.maxLength(255,
                              errorText:
                                  'La città non può superare i 255 caratteri'),
                        ]),
                        name: 'City',
                        decoration: _inputDecoration(context, 'Città').copyWith(
                          errorStyle: TextStyle(color: Colors.redAccent),
                        ),
                        onChanged: (value) {
                          setState(() {
                            city = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: 'Il CAP è obbligatorio'),
                          FormBuilderValidators.match(RegExp(r'^\d{5}$'),
                              errorText:
                                  'Il CAP deve contenere esattamente 5 cifre'),
                        ]),
                        name: 'cap',
                        decoration: _inputDecoration(context, 'CAP').copyWith(
                          errorStyle: TextStyle(color: Colors.redAccent),
                        ),
                        onChanged: (value) async {
                          setState(() {
                            cap = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: FormBuilderTextField(
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(
                                    errorText: 'La via è obbligatoria'),
                                FormBuilderValidators.maxLength(255,
                                    errorText:
                                        'La via non può superare i 255 caratteri'),
                              ]),
                              name: 'street',
                              decoration:
                                  _inputDecoration(context, 'Via').copyWith(
                                errorStyle: TextStyle(color: Colors.redAccent),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  address['street'] = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 1,
                            child: FormBuilderTextField(
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(
                                    errorText:
                                        'Il numero civico è obbligatorio'),
                                FormBuilderValidators.match(RegExp(r'^\d+$'),
                                    errorText:
                                        'Il numero civico può contenere solo cifre'),
                                FormBuilderValidators.maxLength(10,
                                    errorText:
                                        'Il numero civico non può superare i 10 caratteri'),
                              ]),
                              name: 'number',
                              decoration:
                                  _inputDecoration(context, 'Civico').copyWith(
                                errorStyle: TextStyle(color: Colors.redAccent),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  address['number'] = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: Theme.of(context).elevatedButtonTheme.style,
                    onPressed: () => _sendData(email, password, firstName,
                        lastName, city, cap, address),
                    child: const Text(
                      'Registrati',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginUtenteGUI()),
                    );
                  },
                  child: Text(
                    'Sei già registrato? Accedi',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  /// Method to send the login data to the controller.
  /// This method validates the form and sends the email and password to the controller.
  /// If the user is not valid, a snackbar is displayed.
  void _sendData(
      String email,
      String password,
      String firstName,
      String lastName,
      String city,
      String cap,
      Map<String, String> indirizzo) async {
    final formState = _formKey.currentState;
    bool validUser;
    if (formState == null || !formState.saveAndValidate()) {
      return;
    }

    bool isMatching = await isCapMatchingCityAPI(cap, city);
    //print(isMatching);
    if (!isMatching) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: const Text('Il CAP inserito non rispecchia la città'),
        ),
      );
      return;
    }

    // Sends the email and password to the controller.
    UserManagementController controller =
        UserManagementController(redirectPage: HomePage());

    validUser = await controller.register(context,
        email: email,
        password: password,
        name: firstName,
        surname: lastName,
        address: indirizzo,
        city: city,
        cap: cap);
    // If the user is not valid, a snackbar is displayed.
    if (!validUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: const Text('Invalid email or password'),
        ),
      );
    }
  }
}

InputDecoration _inputDecoration(BuildContext context, String? labelText) {
  return InputDecoration(
    labelText: labelText,
    filled: true,
    fillColor: Theme.of(context).colorScheme.onPrimary,
    labelStyle: TextStyle(
      color: Theme.of(context).colorScheme.onPrimaryContainer,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  );
}

/// Verifica se il CAP fornito corrisponde alla città utilizzando un file JSON locale.
///
/// Questo metodo legge un file JSON locale contenente una lista di CAP e città,
/// e controlla se il CAP specificato corrisponde alla città data. Restituisce `true`
/// se il CAP corrisponde alla città, altrimenti `false`.
///
/// Parametri:
/// - [cap]: Il codice postale da verificare.
/// - [city]: Il nome della città da verificare rispetto al CAP.
///
/// Ritorna:
/// - Un `Future<bool>` che risolve a `true` se il CAP corrisponde alla città,
///   altrimenti `false`.
///
/// Esempio:
/// ```dart
/// bool isMatching = await isCapMatchingCityAPI('00100', 'Rome');
/// if (isMatching) {
///   print('Il CAP corrisponde alla città.');
/// } else {
///   print('Il CAP non corrisponde alla città.');
/// }
/// ```

Future<bool> isCapMatchingCityAPI(String cap, String city) async {
  try {
    // Legge il contenuto del file JSON dalla directory "files"
    final jsonData = await rootBundle
        .loadString('assets/files/comuni-localita-cap-italia.json');

    // Decodifica il contenuto del file in una lista di mappe
    final List<dynamic> comuniData =
        json.decode(jsonData)['Sheet 1 - comuni-localita-cap-i'];

    // Cerca se c'è un elemento con il CAP e il Comune corrispondente
    final match = comuniData.any((element) =>
        element['CAP'] == cap &&
        element['Comune Localita’'].toLowerCase() == city.toLowerCase());

    return match; // Restituisce true se corrisponde, altrimenti false
  } catch (e) {
    // In caso di errore (es. file non trovato), stampa il problema e restituisce false
    //print("Errore nel controllo CAP-Città: $e");
    return false;
  }
}

/// A widget to display the login form.
/// This widget is a container that holds the login form.
/// It can be customized with parameters such as padding, color, and alignment.
/// It's a wrapper around the Container widget to provide a more specific name
/// complying to Documentation standards.
class _RegistrationFormWidget extends Container {
  // Parameters could be used later for customization
  // ignore_for_file: unused_element
  _RegistrationFormWidget({
    super.alignment,
    super.padding,
    super.color,
    super.decoration,
    super.foregroundDecoration,
    super.width,
    super.height,
    super.constraints,
    super.margin,
    super.transform,
    super.transformAlignment,
    super.child,
    super.clipBehavior = Clip.none,
  });
}
