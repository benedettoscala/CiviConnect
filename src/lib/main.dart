import 'package:civiconnect/home_page.dart';
import 'package:civiconnect/theme.dart';
import 'package:civiconnect/user_management/login_utente_gui.dart';
import 'package:civiconnect/user_management/registrazione_utente_gui.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:civiconnect/widgets/logo_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'firebase_options.dart';

Future<void> main() async {
  //Firebase Initialization example code
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FirstPage());
}

/// This is the main application widget.
class FirstPage extends StatelessWidget {
  /// This is the main application widget.
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeManager().customTheme,
      home: const _FirstPage(),
      supportedLocales: [
        Locale('it'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FormBuilderLocalizations.delegate,
      ],
    );
  }
}

class _FirstPage extends StatefulWidget {
  const _FirstPage();

  @override
  State<_FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<_FirstPage> {
  @override
  Widget build(BuildContext context) {
    // If the user have already logged in, redirect to the other default page.
    return Scaffold(
      body: UserManagementDAO().currentUser != null
          ? HomePage()
          : Container(
              margin: EdgeInsets.only(bottom: 50),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height / 4),
                      padding: EdgeInsets.only(left: 50, right: 50),
                      child: Column(
                        children: [
                          const LogoWidget(),
                          const SizedBox(height: 50),
                          Text(
                            'Benvenuto in CiviConnect',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                              'Inizia ad utilizzare la nostra applicazione per connetterti con la tua città',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(bottom: 20),
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginUtenteGUI()),
                              );
                            },
                            child: Text('Login'))),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RegistrazioneUtenteGui()),
                            );
                          },
                          child: Text('Registrazione')),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
