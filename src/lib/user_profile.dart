import 'package:civiconnect/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final ThemeData theme = ThemeManager().customTheme;

// Main widget to display user profile (citizen or municipality)
class UserProfile extends StatelessWidget {
  UserProfile({super.key});

  final user = FirebaseAuth.instance.currentUser;

  // Determine user type based on Firestore collections
  Future<String> _getUserType(String uid) async {
    final citizenDoc =
        await FirebaseFirestore.instance.collection('citizen').doc(uid).get();
    if (citizenDoc.exists) return 'citizen';

    final municipalityDoc = await FirebaseFirestore.instance
        .collection('municipality')
        .doc(uid)
        .get();
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
          return _errorScreen('Error loading user data.');
        }

        final userType = snapshot.data!;
        return UserArea(uid: uid, collection: userType);
      },
    );
  }

// Error screen widget
  Widget _errorScreen(String message) {
    return Scaffold(
      body: Center(
        child: Text(
          message,
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}

// UserArea widget to display user data
class UserArea extends StatelessWidget {
  final String uid;
  final String collection;

  const UserArea({super.key, required this.uid, required this.collection});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          collection == 'citizen' ? 'Citizen Area' : 'Municipality Area',
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection(collection).doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading data: ${snapshot.error}',
                style: theme.textTheme.titleMedium,
              ),
            );
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'User data not found.',
                style: theme.textTheme.titleMedium,
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          return _buildContent(userData, collection, theme);
        },
      ),
    );
  }

// Build user data content
  Widget _buildContent(
      Map<String, dynamic> userData, String userType, ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 80,
                child: Icon(Icons.person, size: 80),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Dati Utente',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            if (userType == 'citizen')
              ..._buildCitizenData(userData)
            else
              ..._buildMunicipalityData(userData),
          ],
        ),
      ),
    );
  }

// Build citizen data
  List<Widget> _buildCitizenData(Map<String, dynamic> userData) {
    return [
      InfoRow(label: 'First Name', value: userData['firstName'] ?? 'N/A'),
      InfoRow(label: 'Last Name', value: userData['lastName'] ?? 'N/A'),
      InfoRow(
          label: 'Street',
          value: userData['address']?['street'] ?? 'N/A', other: userData['address']?['number'] ?? 'N/A'),
      InfoRow(label: 'City', value: userData['city'] ?? 'N/A'),
      InfoRow(label: 'Postal Code', value: userData['cap'] ?? 'N/A'),
      const SizedBox(height: 20),
      const Divider(
        thickness: 1,
        color: Color.fromRGBO(0, 69, 118, 1),
      ),
      Text(
        'Dati Account',
        style: theme.textTheme.titleLarge,
      ),
      const SizedBox(height: 20),
      InfoRow(label: 'Email', value: userData['email'] ?? 'N/A'),
      InfoRow(label: 'Password', value: '********'),
    ];
  }

// Build municipality data
  List<Widget> _buildMunicipalityData(Map<String, dynamic> userData) {
    return [
      InfoRow(
          label: 'Municipality Name',
          value: userData['municipalityName'] ?? 'N/A'),
      InfoRow(label: 'Email', value: userData['email'] ?? 'N/A'),
    ];
  }
}

// InfoRow widget to display information row
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String other;

  const InfoRow({super.key, required this.label, required this.value, this.other = ''});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Text(
            other,
            style: const TextStyle(fontSize: 13),
          ),
        )
      ],
    );
  }
}
