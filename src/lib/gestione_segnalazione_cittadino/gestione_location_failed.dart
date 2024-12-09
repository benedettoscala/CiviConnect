import 'package:flutter/material.dart';

/// A page that informs the user that location permissions are disabled.
///
/// This page displays a message and an icon indicating that location services are disabled.
/// It also provides a button to navigate back to the home page.
///
/// Parameters:
/// - [redirectPage]: The page to navigate to when the button is pressed.
class LocationPermissionPage extends StatelessWidget {
/// The page to navigate to when the button is pressed.
final Widget redirectPage;

  /// Constructs a new `LocationPermissionPage` instance.
///
/// Parameters:
/// - [redirectPage]: The page to navigate to when the button is pressed.
const LocationPermissionPage({required this.redirectPage, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Localizzazione disabilitata',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Per utilizzare questa funzionalità, è necessario abilitare la localizzazione sul dispositivo.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => redirectPage),
    );
  },
  child: const Text('Torna alla Home'),
)
          ],
        ),
      ),
    );
  }
}