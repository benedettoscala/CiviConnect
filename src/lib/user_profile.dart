import 'package:civiconnect/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A stateful widget to display the user profile.
class UserProfile extends StatefulWidget {
  UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool isEditing = false;
  Map<String, dynamic> userData = {};

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeManager().customTheme;
    final user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;

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
            userData = snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 0),
                    _buildProfileHeader(theme, user, userData),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dati Personali',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(isEditing ? Icons.save : Icons.edit),
                          onPressed: () {
                            setState(() {
                              isEditing = !isEditing;
                              if (!isEditing) {
                                /// Save the updated userData to Firestore
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._buildPersonalData(userData, theme),
                    const SizedBox(height: 20),
                    const Divider(
                      thickness: 1,
                      height: 10,
                      color: Color.fromRGBO(0, 69, 118, 1),
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

  Widget _buildProfileHeader(ThemeData theme, User user, Map<String, dynamic> userData) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 80,
            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null ? Icon(Icons.person, size: 80) : null,
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

  List<Widget> _buildPersonalData(Map<String, dynamic> userData, ThemeData theme) {
    final List<Map<String, String>> personalFields = [
      {'Nome': userData['firstName'] ?? 'N/A'},
      {'Cognome': userData['lastName'] ?? 'N/A'},
      {'Indirizzo': userData['address']['street'] ?? 'N/A'},
      {'Città': userData['city'] ?? 'N/A'},
      {'CAP': userData['CAP'] ?? 'N/A'},
    ];

    TextStyle textStyle = theme.textTheme.titleMedium!.copyWith(fontSize: 16);

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
                style: textStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 3,
              child: isEditing
                  ? TextFormField(
                initialValue: field.values.first,
                style: textStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                onFieldSubmitted: (newValue) {
                  setState(() {
                    userData[field.keys.first.toLowerCase()] = newValue;
                  });
                },
              )
                  : Text(
                field.values.first,
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    )
        .toList();
  }

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
                '********',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}