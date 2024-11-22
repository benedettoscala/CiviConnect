import 'package:civiconnect/user_management/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginUtenteGUI extends StatefulWidget {
  const LoginUtenteGUI({super.key});
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
                SvgPicture.asset('images/logo_blu.svg', fit: BoxFit.none, height: 250, width: 250, semanticsLabel: 'Logo CiviConnect',
                  placeholderBuilder: (BuildContext context) => const CircularProgressIndicator(backgroundColor: Colors.blue),
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

  void _sendData(String email, String password) {
    final formState = _formKey.currentState;
    if (formState == null || !formState.saveAndValidate()) return;

    UserManagementController controller = UserManagementController();
    controller.login(context, email: email, password: password);
  }

}


class _LoginFormWidget extends Container {
  _LoginFormWidget({
  this.alignment,
  this.padding,
  this.color,
  this.decoration,
  this.foregroundDecoration,
  this.width,
  this.height,
  this.constraints,
  this.margin,
  this.transform,
  this.transformAlignment,
  this.child,
  this.clipBehavior = Clip.none,
    
}) : super (
  alignment: alignment,
  padding: padding,
  color: color,
  decoration: decoration,
  foregroundDecoration: foregroundDecoration,
  margin: margin,
  transform: transform,
  transformAlignment: transformAlignment,
  child: child,
  clipBehavior: clipBehavior,
  constraints: constraints,
  width: width,
  height: height,
);
  
  
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Widget? child;
  final Clip clipBehavior;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  
}