import 'package:civiconnect/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
class UserProfile extends StatelessWidget {
  UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeManager().customTheme;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("L'utente non è autenticato");
    } else {
      print("Utente autenticato: ${user.email}");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Area Utente",
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { //controlliamo stato dell utente
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Something went wrong: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return Center(child: Text("User is not signed in"));
          } else {
            final user = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : AssetImage('src/web/favicon.png') as ImageProvider, //Qui andrebbe messa un img di base, in caso di error mostra quella
                      ),
                    ),
                    Center(
                      child: Text(
                        "Bentornato, ${user.displayName ?? 'User'}!",
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Dati Personali",
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Nome: ${user.displayName ?? 'N/A'}",
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      "E-Mail: ${user.email ?? 'N/A'}",
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      "Indirizzo:}",
                      style: theme.textTheme.titleMedium,

                    ),
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
            icon: Icon(Icons.person),
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
}
