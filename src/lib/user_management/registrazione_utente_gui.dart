import 'dart:convert';

import 'package:civiconnect/theme.dart';
import 'package:civiconnect/user_management/user_management_controller.dart';
import 'package:civiconnect/widgets/input_textfield_decoration.dart';
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
  RegistrazioneUtenteGui({super.key, UserManagementController? controller})
      : _controller = (controller == null)
            ? UserManagementController(redirectPage: const HomePage())
            : controller;

  final UserManagementController _controller;

  @override
  State<RegistrazioneUtenteGui> createState() => _RegistrazioneUtenteGuiState(_controller);
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
  bool obscureText = true;
  final _formKey = GlobalKey<FormBuilderState>();
  // Sends the email and password to the controller.
  late UserManagementController _controller;
  final _passKey = Key('passwordField');
  final _emailKey = Key('emailField');
  final _firstNameKey = Key('nameField');
  final _lastNameKey = Key('surnameField');
  final _cityKey = Key('cityField');
  final _capKey = Key('capField');
  final _streetKey = Key('viaField');
  final _numberKey = Key('civicoField');
  
  _RegistrazioneUtenteGuiState(UserManagementController? controller) {
    _controller = controller ?? UserManagementController(redirectPage: const HomePage());
  }

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
                const Hero(
                  child: LogoWidget(),
                  tag: 'logo_from_home',
                ),
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
                        key: _emailKey,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.email(),
                          FormBuilderValidators.required(),
                        ]),
                        name: 'email',
                        maxLength: 255,
                        decoration: TextFieldInputDecoration(context,
                            labelText: 'Email'),
                        onChanged: (value) {
                          setState(() {
                            email = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        key: _passKey,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.password(
                              minLength: 8, maxLength: 4096),
                          FormBuilderValidators.required(),
                        ]),
                        obscureText: obscureText,
                        name: 'password',
                        maxLength: 4096,
                        decoration: TextFieldInputDecoration(context,
                            labelText: 'Password',
                            obscureText: obscureText, onObscure: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        }),
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
                        key: _firstNameKey,
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
                        maxLength: 255,
                        decoration: TextFieldInputDecoration(context,
                            labelText: 'Nome'),
                        onChanged: (value) {
                          setState(() {
                            firstName = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        key: _lastNameKey,
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
                        maxLength: 255,
                        decoration: TextFieldInputDecoration(context,
                            labelText: 'Cognome'),
                        onChanged: (value) {
                          setState(() {
                            lastName = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        key: _cityKey,
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
                        maxLength: 255,
                        decoration: TextFieldInputDecoration(context,
                            labelText: 'Città'),
                        onChanged: (value) {
                          setState(() {
                            city = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        key: _capKey,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: 'Il CAP è obbligatorio'),
                          FormBuilderValidators.match(RegExp(r'^\d{5}$'),
                              errorText:
                                  'Il CAP deve contenere esattamente 5 cifre'),
                        ]),
                        name: 'cap',
                        maxLength: 5,
                        decoration:
                            TextFieldInputDecoration(context, labelText: 'CAP'),
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
                              key: _streetKey,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(
                                    errorText: 'La via è obbligatoria'),
                                FormBuilderValidators.maxLength(255,
                                    errorText:
                                        'La via non può superare i 255 caratteri'),
                              ]),
                              name: 'street',
                              maxLength: 255,
                              decoration: TextFieldInputDecoration(context,
                                  labelText: 'Via'),
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
                              key: _numberKey,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(
                                    errorText: 'N. Civico obbligatorio'),
                                FormBuilderValidators.match(RegExp(r'^\d+$'),
                                    errorText:
                                        'Il numero civico può contenere solo cifre'),
                                FormBuilderValidators.maxLength(10,
                                    errorText:
                                        'Il numero civico non può superare i 10 caratteri'),
                              ]),
                              name: 'number',
                              maxLength: 10,
                              decoration: TextFieldInputDecoration(context,
                                  labelText: 'Civico'),
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
                    key: const Key('registerButton'),
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

    bool isMatching = await _controller.isCapMatchingCityAPI(cap, city);
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

    validUser = await _controller.register(context,
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
