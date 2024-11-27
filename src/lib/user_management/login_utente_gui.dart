import 'package:civiconnect/theme.dart';
import 'package:civiconnect/user_management/user_management_controller.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hugeicons/hugeicons.dart';

import '../home_page.dart';
import '../main.dart';
import '../widgets/logo_widget.dart';

/// A stateful widget to wrap the login form.
class LoginUtenteGUI extends StatefulWidget {
  /// Constructs a new instance of [LoginUtenteGUI].
  const LoginUtenteGUI({super.key});

  /// The title of the login page.
  final String title = 'Login';

  @override
  State<LoginUtenteGUI> createState() => _LoginUtenteGUIState();
}

class _LoginUtenteGUIState extends State<LoginUtenteGUI> {
  String email = '';
  String password = '';
  bool obscureText = true;
  FocusNode focusNode = FocusNode();
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager().seedColor,
      body: _LoginFormWidget(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        alignment: Alignment.center,
        child: Column(
          children: [
            /// Logo
            const LogoWidget(),
            /// Form
            FormBuilder(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Benvenuto',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FormBuilderTextField(
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.max(255),
                      FormBuilderValidators.email(),
                      FormBuilderValidators.required(),
                    ]),
                    name: 'email',
                    textInputAction: TextInputAction.continueAction,
                    maxLength: 255,
                    keyboardType:  TextInputType.emailAddress,
                    decoration: _inputDecoration(context, labelText: 'Email'),
                    onChanged: (value) {
                      setState(() {
                        email = value!;
                      });
                    },
                    onSubmitted: (value) {
                      focusNode.nextFocus();
                    },
                  ),
                  const SizedBox(height: 20),
                  FormBuilderTextField(
                    focusNode: focusNode,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.password(
                          minLength: 6, maxLength: 255),
                      FormBuilderValidators.required(),
                    ]),
                    obscureText: obscureText,
                    maxLength: 255,
                    name: 'password',
                    decoration:
                    _inputDecoration(
                        context,
                        labelText: 'Password',
                        obscureText: obscureText,
                        onObscure: () {
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
                      _sendData(email, password);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: Theme.of(context).elevatedButtonTheme.style,
                onPressed: () => _sendData(email, password),
                child: const Text(
                  'Login',
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// Bottom buttons
            _BottomLoginRedirectButtons(),
          ],
        ),
      ),
    );

  }

  /// Method to send the login data to the controller.
  /// This method validates the form and sends the email and password to the controller.
  /// If the user is not valid, a snackbar is displayed.
  void _sendData(String email, String password) async {
    final formState = _formKey.currentState;
    bool validUser;
    if (formState == null || !formState.saveAndValidate()) {
      return;
    }
    // Sends the email and password to the controller.
    UserManagementController controller =
        UserManagementController(redirectPage: HomePage());

    validUser =
        await controller.login(context, email: email, password: password);

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


// ----------------------------- PRIVATE METHODS --------------------------------

/// A method to create the input decoration for the text form fields.
/// This method creates a new instance of InputDecoration with the provided
/// labelText and returns it.
///
/// The decoration is filled with the color scheme of the current theme onPrimary.
///
/// The icon is displayed only if the `onObscure` callback parameter is not null.
/// The icon changes based on the `obscureText` parameter.
/// The `onObscure` parameter is a callback that is called when the icon is pressed.
///
InputDecoration _inputDecoration(BuildContext context, {String? labelText, VoidCallback? onObscure,
                        bool obscureText = false}) {
  return InputDecoration(
    /// The icon is displayed only if the onObscure callback parameter is not null.
    /// The icon changes based on the obscureText parameter.
    /// The onObscure callback is called when the icon is pressed.
    suffixIcon: (onObscure == null) ? null :
    Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: IconButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Theme.of(context).shadowColor.withAlpha(20)),
          animationDuration: const Duration(milliseconds: 200),
          elevation: WidgetStatePropertyAll(2),
        ),
        tooltip: 'Mostra/Nascondi password',
        icon: obscureText ? HugeIcon(
          icon: HugeIcons.strokeRoundedViewOff,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        )
            :
        HugeIcon(
            icon: HugeIcons.strokeRoundedView,
            color: Theme.of(context).colorScheme.onPrimaryContainer
        ),
        color: Theme.of(context).colorScheme.onPrimary,
        onPressed: () {
          onObscure.call();
        },
      ),
    ),
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
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: (){}, //TODO: Implement password recovery
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
                    MaterialPageRoute(builder: (context) => RegistrazioneUtenteGui()),
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
      ),
    );
  }
}



// ----------------------------- TESTING PAGE --------------------------------


/// UI page for testing login functionality.
class TestingPage extends StatelessWidget {
  /// Constructs a new instance of [TestingPage].
  const TestingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logged'),
      ),
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                UserManagementDAO().logOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FirstPage()),
                );
              },
              child: Text('Logout'),
            ),
            ElevatedButton(
              onPressed: () {
                UserManagementDAO().determineUserType().then((value) {
                  print('\n\n\n[Testing] Type of user: ${value.name}');
                });
              },
              child: Text('Test if I\' m admin'),
            ),
          ],
        ),
      ),
    );
  }
}
