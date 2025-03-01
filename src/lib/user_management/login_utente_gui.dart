import 'dart:io';

import 'package:civiconnect/theme.dart';
import 'package:civiconnect/user_management/registrazione_utente_gui.dart';
import 'package:civiconnect/user_management/user_management_controller.dart';
import 'package:civiconnect/widgets/input_textfield_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../home_page.dart';
import '../widgets/logo_widget.dart';

/// A stateful widget to wrap the login form.
class LoginUtenteGUI extends StatefulWidget {
  /// Constructs a new instance of [LoginUtenteGUI].
  LoginUtenteGUI({super.key, UserManagementController? controller})
      : _controller = (controller == null)
            ? UserManagementController(redirectPage: const HomePage())
            : controller;

  /// The title of the login page.
  final String title = 'Login';
  final UserManagementController? _controller;

  @override
  State<LoginUtenteGUI> createState() => _LoginUtenteGUIState(_controller);
}

class _LoginUtenteGUIState extends State<LoginUtenteGUI> {
  String email = '';
  String password = '';
  bool obscureText = true;
  FocusNode focusNode = FocusNode();
  final _formKey = GlobalKey<FormBuilderState>();
  final _passKey = GlobalKey<FormBuilderFieldState>();
  final _emailKey = GlobalKey<FormBuilderFieldState>();
  late final UserManagementController _controller;

  _LoginUtenteGUIState(UserManagementController? controller) {
    _controller =
        controller ?? UserManagementController(redirectPage: const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    double padding = MediaQuery.of(context).size.width / 15;
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeManager().seedColor,
        body: _LoginFormWidget(
          padding: EdgeInsets.symmetric(horizontal: padding),
          margin: const EdgeInsets.only(bottom: 50),
          alignment: Alignment.center,
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /// Logo
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: EdgeInsets.only(left: padding, right: padding),
                      child: Column(
                        children: [
                          const Hero(
                            child: LogoWidget(),
                            tag: 'logo_from_home',
                          ),

                          /// Form
                          FormBuilder(
                            key: _formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  textAlign: TextAlign.center,
                                  'Accedi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                FormBuilderTextField(
                                  key: _emailKey,
                                  cursorErrorColor:
                                      Theme.of(context).colorScheme.error,
                                  textAlignVertical: TextAlignVertical.center,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.maxLength(255),
                                    FormBuilderValidators.email(),
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.match(
                                      // Note: order of validators is important
                                      RegExp(r'^[a-zA-Z0-9.+@_\-]+$'),
                                      errorText:
                                          'Inserito carattere non valido',
                                    ),
                                  ]),
                                  name: 'email',
                                  //textInputAction: TextInputAction.continueAction, // Bricks user input on mobile to be checked in future
                                  maxLength: 255,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: TextFieldInputDecoration(context,
                                      labelText: 'Email'),
                                  onChanged: (value) {
                                    setState(() {
                                      email = value!;
                                    });
                                  },
                                  onSubmitted: (value) {
                                    focusNode.nextFocus();
                                  },
                                ),
                                const SizedBox(height: 10),
                                FormBuilderTextField(
                                  key: _passKey,
                                  cursorErrorColor:
                                      Theme.of(context).colorScheme.error,
                                  focusNode: focusNode,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.password(
                                        minLength: 8, maxLength: 255),
                                    FormBuilderValidators.required(),
                                  ]),
                                  obscureText: obscureText,
                                  maxLength: 255,
                                  name: 'password',
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
                                  onSubmitted: (value) {
                                    // Sends the email and password to the controller.
                                    _sendData(_controller, email, password);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () =>
                                  _sendData(_controller, email, password),
                              child: const Text(
                                'Login',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Bottom buttons
                    const _BottomLoginRedirectButtons(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Method to send the login data to the controller.
  /// This method validates the form and sends the email and password to the controller.
  /// If the user is not valid, a snackbar is displayed.
  void _sendData(UserManagementController controller, String email,
      String password) async {
    String motivation = 'Invalid email or password';
    final formState = _formKey.currentState;
    bool validUser = false;
    if (formState == null || !formState.saveAndValidate()) {
      return;
    }
    try {
      validUser =
          await controller.login(context, email: email, password: password);
    } on HttpException catch (e) {
      motivation = e.message;
      validUser = false;
    } finally {
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
            content: Text(motivation),
          ),
        );
      }
    }
  }
}

// ----------------------------- PRIVATE CLASSES --------------------------------

/// A widget to display the login form.
/// This widget is a container that holds the login form.
/// It can be customized with parameters such as padding, color, and alignment.
/// It's a wrapper around the Container widget to provide a more specific name
/// complying to Documentation standards.
class _LoginFormWidget extends Container {
  // Parameters could be used later for customization
  // ignore_for_file: unused_element
  _LoginFormWidget({
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

/// A widget to display the bottom buttons for the login page.
/// It contains two buttons: one for password recovery and one for registration.
/// The buttons are styled with the color scheme of the current theme.
/// The buttons are aligned at the bottom of the screen.
class _BottomLoginRedirectButtons extends StatelessWidget {
  const _BottomLoginRedirectButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {}, //TODO: Implement password recovery
              child: Text(
                'Password dimenticata?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  shadows: const [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegistrazioneUtenteGui()),
                );
              },
              child: Text(
                'Non hai un account? Registrati',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  shadows: const [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 2,
                      offset: Offset(0, 1),
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
