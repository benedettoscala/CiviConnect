import 'package:flutter/material.dart';

class LocationPermissionPage extends StatelessWidget {
  final VoidCallback onRetry;
  final Widget redirectPage;

  const LocationPermissionPage({super.key, required this.onRetry, required Widget this.redirectPage});

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
    onRetry();
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