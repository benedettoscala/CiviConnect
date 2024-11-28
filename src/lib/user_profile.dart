import 'package:civiconnect/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeManager().customTheme;
    final user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;
    /* test
    if (user == null) {
      print("L'utente non è autenticato");
    } else {
      print('Utente autenticato: ${user.email}');
    }*/

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Area Utente',
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
                'Something went wrong: ${snapshot.error}',
                style: theme.textTheme.titleMedium,
              ),
            );
          } else {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 0),
                    _buildProfileHeader(theme, user, userData),
                    const SizedBox(height: 30),
                    Text(
                      'Dati Personali',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ..._buildPersonalData(userData, theme),
                    const SizedBox(height: 20),
                    const Divider(
                      thickness: 1, // Spessore della linea
                      height: 10,   // Altezza della linea e spazio intorno
                      color: Color.fromRGBO(0, 69, 118, 1), // Colore della linea
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Dati Account',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildAccountData(user, theme),
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Segnalazioni',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }

  // Widget per l'header con immagine e benvenuto
  Widget _buildProfileHeader(
      ThemeData theme, User user, Map<String, dynamic> userData) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 80,
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
            child: user.photoURL == null
                ? Icon(
              Icons.person,
              size: 80,
            )
                : null,
          ),
          const SizedBox(height: 5),
          Text(
            "Bentornato, ${userData['firstName'] ?? 'User'}!",
            style: theme.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  // Funzione per costruire i dati personali
  List<Widget> _buildPersonalData(Map<String, dynamic> userData, ThemeData theme) {
    final List<Map<String, String>> personalFields = [
      {'Nome': userData['firstName'] ?? 'N/A'},
      {'Cognome': userData['lastName'] ?? 'N/A'},
      {'Indirizzo': userData['address']['street'] ?? 'N/A'},
      {'Città': userData['city'] ?? 'N/A'},
      {'CAP': userData['CAP'] ?? 'N/A'},
    ];

    return personalFields
        .map(
          (field) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '${field.keys.first}:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                field.values.first,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    )
        .toList();
  }

  // Widget per i dati dell'account
  Widget _buildAccountData(User user, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Email:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                user.email ?? 'N/A',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Password:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '********', // Puoi gestire la modifica della password separatamente
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}