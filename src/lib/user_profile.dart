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
    final theme = Theme.of(context);

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
          return _buildContent(userData, theme);
        },
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> userData, ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar centrato
            Center(
              child: CircleAvatar(
                radius: 80,
                child: Icon(Icons.person, size: 80),
              ),
            ),
            const SizedBox(height: 20),
            // Sezione Dati Personali
            Text(
              'Dati Personali',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ..._buildPersonalData(userData, theme),
            const SizedBox(height: 20),
            const Divider(
              thickness: 1,
              color: Color.fromRGBO(0, 69, 118, 1),
            ),
            const SizedBox(height: 20),
            // Sezione Dati Account
            Text(
              'Dati Account',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
           text_widget(boldText: 'Email', normalText: userData['email'] ?? 'N/A'),
            const SizedBox(height: 10),
            text_widget(boldText: 'Password', normalText: '******'),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPersonalData(Map<String, dynamic> userData, ThemeData theme) {
    return [
      Text(
        'Nome: ${userData['firstName'] ?? 'N/A'}',
        style: theme.textTheme.titleMedium,
      ),
      Text(
        'Cognome: ${userData['lastName'] ?? 'N/A'}',
        style: theme.textTheme.titleMedium,
      ),
      Text(
        'Indirizzo: ${userData['address']?['street'] ?? 'N/A'}',
        style: theme.textTheme.titleMedium,
      ),
      Text(
        'Città: ${userData['city'] ?? 'N/A'}',
        style: theme.textTheme.titleMedium,
      ),
      Text(
        'CAP: ${userData['CAP'] ?? 'N/A'}',
        style: theme.textTheme.titleMedium,
      ),
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
              'Benvenuto, Comune di ${municipalityData['municipalityName'] ?? 'N/A'}!',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            // Nome con grassetto e spaziatura
            /*
            Text(
              'Nome: ',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text('${municipalityData['municipalityName'] ?? 'N/A'}'),
            const SizedBox(height: 10), // Aggiungi spazio tra Nome e Email
            */
            // Email con grassetto e spaziatura
            /*
            Text(
              'Email: ',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text('${municipalityData['email'] ?? 'N/A'}'),
            const SizedBox(height: 10), // Aggiungi spazio tra Email e Provincia
            */
            text_widget(boldText: "Email:", normalText: '${municipalityData['email'] ?? 'N/A'}'),
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


class text_widget extends StatelessWidget {
  final String boldText;
  final String normalText;
  

  text_widget({super.key, required this.boldText,required this.normalText});

  @override
  Widget build(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      //first column
      Expanded(
          flex:2,
          child: Text(

        boldText,
        style: const TextStyle(fontWeight: FontWeight.bold),

      )),

      //second column
      Expanded(
          flex:2,
          child: Text(
        normalText,
            style: const TextStyle(fontSize: 13),

      )),
    ],


  );

  }
}