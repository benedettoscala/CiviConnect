import 'package:civiconnect/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final ThemeData theme = ThemeManager().customTheme;

class UserProfile extends StatelessWidget {
  UserProfile({super.key});

  final user = FirebaseAuth.instance.currentUser;

  Future<String> _getUserType(String uid) async {
    final citizenDoc = await FirebaseFirestore.instance.collection('citizen').doc(uid).get();
    if (citizenDoc.exists) return 'citizen';

    final municipalityDoc = await FirebaseFirestore.instance.collection('municipality').doc(uid).get();
    if (municipalityDoc.exists) return 'municipality';

    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    String uid = user!.uid;

    return FutureBuilder<String>(
      future: _getUserType(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || snapshot.data == 'unknown') {
          return Scaffold(
            body: Center(
              child: Text(
                'Errore nel caricamento dei dati utente.',
                style: theme.textTheme.titleMedium,
              ),
            ),
          );
        }

        final userType = snapshot.data!;
        if (userType == 'citizen') {
          return CitizenArea(uid: uid);
        } else if (userType == 'municipality') {
          return MunicipalityArea(uid: uid);
        } else {
          return Scaffold(
            body: Center(
              child: Text(
                'Tipo utente non riconosciuto.',
                style: theme.textTheme.titleMedium,
              ),
            ),
          );
        }
      },
    );
  }
}

class CitizenArea extends StatelessWidget {
  final String uid;

  CitizenArea({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Area Cittadino',
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('citizen').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Errore nel caricamento dei dati: ${snapshot.error}',
                style: theme.textTheme.titleMedium,
              ),
            );
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Dati utente non trovati.',
                style: theme.textTheme.titleMedium,
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          return _buildContent(userData);
        },
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> userData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0),
            Text(
              'Benvenuto, ${userData['firstName'] ?? 'Cittadino'}!',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ..._buildPersonalData(userData),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPersonalData(Map<String, dynamic> userData) {
    return [
      Text('Nome: ${userData['firstName'] ?? 'N/A'}'),
      Text('Cognome: ${userData['lastName'] ?? 'N/A'}'),
      Text('Indirizzo: ${userData['address']?['street'] ?? 'N/A'}'),
      Text('Città: ${userData['city'] ?? 'N/A'}'),
      Text('CAP: ${userData['CAP'] ?? 'N/A'}'),
    ];
  }
}

class MunicipalityArea extends StatelessWidget {
  final String uid;

  MunicipalityArea({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Area Comune',
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('municipality').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Errore nel caricamento dei dati: ${snapshot.error}',
                style: theme.textTheme.titleMedium,
              ),
            );
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Dati comune non trovati.',
                style: theme.textTheme.titleMedium,
              ),
            );
          }

          final municipalityData = snapshot.data!.data() as Map<String, dynamic>;
          return _buildContent(municipalityData);
        },
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> municipalityData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0),
            Text(
              'Benvenuto, Comune di ${municipalityData['name'] ?? 'Municipality'}!',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            // Nome con grassetto e spaziatura
            Text(
              'Nome: ',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text('${municipalityData['municipalityName'] ?? 'N/A'}'),
            const SizedBox(height: 10), // Aggiungi spazio tra Nome e Email

            // Email con grassetto e spaziatura
            Text(
              'Email: ',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text('${municipalityData['email'] ?? 'N/A'}'),
            const SizedBox(height: 10), // Aggiungi spazio tra Email e Provincia

            // Provincia con grassetto e spaziatura
            Text(
              'Provincia: ',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text('${municipalityData['province'] ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}