import 'package:civiconnect/home_page.dart';
import 'package:civiconnect/theme.dart';
import 'package:civiconnect/user_management/login_utente_gui.dart';
import 'package:civiconnect/user_management/registrazione_utente_gui.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:civiconnect/widgets/logo_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

Future<void> main() async {
  //Firebase Initialization example code

  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(
      name: 'civiconnect-13aeb',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Init Hive for Local Storage
  await Hive.initFlutter();
  // Open box called "settings"
  await Hive.openBox('settings');

  runApp(const FirstPage());
}

/// This is the main application widget.
class FirstPage extends StatelessWidget {
  /// This is the main application widget.
  const FirstPage({super.key, this.isLogout});

  /// This notify the user after logout. (The user will be redirected to
  /// the login page, so i need a parameter for check the reason of Navigation).
  final bool? isLogout;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeManager().customTheme,
      home: _FirstPage(isLogout: isLogout),
      supportedLocales: const [
        Locale('it'),
      ],
      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        FormBuilderLocalizations.delegate,
      ],
    );
  }
}

class _FirstPage extends StatefulWidget {
  const _FirstPage({this.isLogout});
  final bool? isLogout;

  @override
  State<_FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<_FirstPage> {
  @override
  void initState() {
    super.initState();
    if (widget.isLogout ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        const message = 'Logout effettuato con successo';

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 7),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Change color navgationbar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: ThemeManager().seedColor,
    ));
    // If the user have already logged in, redirect to the other default page.
    return Scaffold(
      backgroundColor: ThemeManager().seedColor,
      body: UserManagementDAO().currentUser != null
          ? const HomePage()
          : Container(
              margin: const EdgeInsets.only(bottom: 50),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height / 4),
                      padding: const EdgeInsets.only(left: 50, right: 50),
                      child: const Column(
                        children: [
                          Hero(
                            child: LogoWidget(),
                            tag: 'logo_from_home',
                          ),
                          SizedBox(height: 50),
                          Text(
                            'Benvenuto in CiviConnect',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Inizia ad utilizzare la nostra applicazione per connetterti con la tua città',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              _transitionAnimationLogin(
                                  (context) => LoginUtenteGUI()),
                            );
                            /*MaterialPageRoute(
                          builder: (context) => LoginUtenteGUI()),
                      );*/
                          },
                          child: const Text('Login')),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              _transitionAnimationLogin(
                                  (context) => RegistrazioneUtenteGui()),
                            );
                          },
                          child: const Text('Registrazione')),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Add a transition animation to the login page.
/// This is a custom transition animation that slides the page from the bottom to the top.
PageRouteBuilder _transitionAnimationLogin(
    Widget Function(BuildContext context) function) {
  return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) =>
          function(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // You can change the begin and end values to customize the animation.
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.easeInOut;

        // Tween is a linear interpolation between two values.
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        // Drive animation changes the value of the animation using interpolated values of the tween.
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      });
}
