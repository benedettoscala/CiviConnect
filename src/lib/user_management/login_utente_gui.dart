import 'package:civiconnect/user_management/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body:
      _LoginFormWidget(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Column(
          children: [
            ClipRRect(
                borderRadius:BorderRadius.circular(125.0),
                child:
                SvgPicture.asset('assets/images/logo_blu.svg', fit: BoxFit.none, height: 250, width: 250, semanticsLabel: 'Logo CiviConnect',
                  placeholderBuilder: (context) => const CircularProgressIndicator(backgroundColor: Colors.blue),
                )
            ),
            FormBuilder(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FormBuilderTextField(
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.email(),
                      FormBuilderValidators.required(),
                    ]),
                    name: 'email',
                    decoration: const InputDecoration(labelText: 'Email'),
                    onChanged: (value) {
                      setState(() {
                        email = value!;
                      });
                    },
                  ),
                  FormBuilderTextField(
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.password(minLength: 6, maxLength: 4096),
                      FormBuilderValidators.required(),
                    ]),
                    obscureText: true,

                    name: 'password',
                    decoration: const InputDecoration(labelText: 'Password'),
                    onChanged: (value) {
                      setState(() {
                        password = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                style: Theme.of(context).elevatedButtonTheme.style,
                onPressed: () => _sendData(email, password),
                child: const Text(
                  'Login',
                ),
              ),
            ),
          ],
        ),
      ),
    );


  }

  void _sendData(String email, String password) async {
    final formState = _formKey.currentState;
    bool validUser;
    if (formState == null || !formState.saveAndValidate()) {
      return;
    }

    UserManagementController controller = UserManagementController();
    validUser = await controller.login(context, email: email, password: password);
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


class _LoginFormWidget extends Container {
  _LoginFormWidget({
  AlignmentGeometry? alignment,
  EdgeInsetsGeometry? padding,
  Color? color,
  Decoration? decoration,
  Decoration? foregroundDecoration,
  double? width,
  double? height,
  BoxConstraints? constraints,
  EdgeInsetsGeometry? margin,
  Matrix4? transform,
  AlignmentGeometry? transformAlignment,
  Widget? child,
  Clip clipBehavior = Clip.none,

}) : super(
    alignment: alignment,
    padding: padding,
    color: color,
    decoration: decoration,
    foregroundDecoration: foregroundDecoration,
    width: width,
    height: height,
    constraints: constraints,
    margin: margin,
    transform: transform,
    transformAlignment: transformAlignment,
    child: child,
    clipBehavior: clipBehavior,
  );
}