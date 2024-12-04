import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>{
  List<Map<String, String>> _allComuni = [];
  List<Map<String, String>> _filteredComuni = [];
  String _searchText = '';
  Map<String, String>? _selectedComune;
  String? _generatedEmail;
  String? _generatedPassword;
  bool _isComuneExisting = false;

  @override
  void initState() {
    super.initState();
    _loadComuni();
  }

  void _loadComuni() async {
    // Load all comuni from the JSON file
    String data = await DefaultAssetBundle.of(context)
        .loadString('assets/comuni-localita-cap-italia.json');
    Map<String, dynamic> jsonResult = json.decode(data);

    // Extract the name and province from jason
    List<dynamic> comuniList = jsonResult["Sheet 1 - comuni-localita-cap-i"];
    setState(() {
      _allComuni = comuniList
          .map((comune) => {
        'Comune': comune["Comune Localita’"].toString(),
        'Provincia': comune["Provincia"].toString(),
      })
          .toSet()
          .toList(); // Rimuove duplicati
      _filteredComuni = _allComuni;
    });
  }

  void _filterComuni(String query) {
    List<Map<String, String>> suggestions = _allComuni
        .where((comune) =>
        comune['Comune']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Pick the first 7 suggestion
    if (suggestions.length > 7) {
      suggestions = suggestions.sublist(0, 7);
    }

    setState(() {
      _filteredComuni = suggestions;
      _searchText = query;
    });
  }

  Future<void> _onComuneSelected(Map<String, String> comuneSelezionato) async {
    bool exists = await _comuneExistsInDatabase(comuneSelezionato['Comune']!);
    setState(() {
      _selectedComune = comuneSelezionato;
      _isComuneExisting = exists;
    });
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comune già presente nel database')),
      );
    }
  }
  
  Future<bool> _comuneExistsInDatabase(String comune) async {
    // Check if the comune is already in the database
    try{
      final querySnapshot = await FirebaseFirestore.instance
          .collection('municipality')
          .where('municipalityName', isEqualTo: comune)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Errore nel controllare il database: $e');
      return false;
    }
  }

  void _generateCredentials(){
    String comuneEmailPart = _selectedComune!['Comune']!.toLowerCase().replaceAll(' ', '');
    String email = 'comune.$comuneEmailPart@anci.gov';
    String password = _generatePassword();

    // Save the credential in Firebase
    _saveCredentialsToDatabase(email, password);

  }

  String _generatePassword() {
    const length = 15;
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const special = '!@#\$%&*?';

    final allChars = uppercase + lowercase + numbers + special;
    final rand = Random.secure();

    String password = '';
    password += uppercase[rand.nextInt(uppercase.length)];
    password += lowercase[rand.nextInt(lowercase.length)];
    password += numbers[rand.nextInt(numbers.length)];
    password += special[rand.nextInt(special.length)];

    for (int i = 4; i < length; i++) {
      password += allChars[rand.nextInt(allChars.length)];
    }

    // Mix character of password
    List<String> passwordChars = password.split('');
    passwordChars.shuffle();
    return passwordChars.join();
  }

  Future<void> _saveCredentialsToDatabase(String email, String password) async{
    try{
      // Create user in Firestore
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save Comune data in Firestore
      await FirebaseFirestore.instance
          .collection('municipality')
          .doc(userCredential.user!.uid)
          .set({
        'municipalityName': _selectedComune!['Comune'],
        'email': email,
        'province': _selectedComune!['Provincia'],
      });
    } catch (e){
      // Gestisci eventuali errori
      print('Errore nel salvataggio delle credenziali: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ben Tornato Supremo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Cerca Comune',
              ),
              onChanged: _filterComuni,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredComuni.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_filteredComuni[index]['Comune']!),
                    subtitle: Text('Provincia: ${_filteredComuni[index]['Provincia']!}'),
                    onTap: () {
                      _onComuneSelected(_filteredComuni[index]);
                    },
                  );
                },
              ),
            ),
            if (_selectedComune != null)
              Column(
                children: [
                  _isComuneExisting
                      ? const Text(
                    'Comune già presente nel database',
                    style: TextStyle(color: Colors.red),
                  )
                      : ElevatedButton(
                    onPressed: _generateCredentials,
                    child: const Text('Genera Credenziali'),
                  ),
                ],
              ),
            if (_generatedEmail != null && _generatedPassword != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: $_generatedEmail'),
                  Text('Password: $_generatedPassword'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}