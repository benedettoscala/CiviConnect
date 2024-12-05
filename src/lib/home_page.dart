import 'package:civiconnect/gestione_segnalazione/dettagli_segnalazione_gui.dart';
import 'package:civiconnect/user_management/user_profile_gui.dart';
import 'package:civiconnect/utils/report_status_priority.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'model/report_model.dart';

/// Home page of the application.
class HomePage extends StatefulWidget {
  /// Home page of the application.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class TestingPage extends StatelessWidget {
  const TestingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DettagliSegnalazione(
                  report: Report(
                    description: 'descrizione descriziosa discrizione indiscreta della descrizione ',
                    photo: null,
                    address: {
                      'street': 'Via Benedetto',
                      'number': '69',
                    },
                    city: 'City',
                    uid: 'BILgzGbWKQVMKhVLiVOytoyzOwT2',
                    title: 'Titolo super sexy',
                    status: StatusReport.inProgress,
                    priority: PriorityReport.high,
                    reportDate: Timestamp.now(),
                    authorFirstName: 'Manuel',
                    authorLastName: 'Cieri',
                  ),
                ),
              ),
            );
          },
          child: const Text('button')),
    );
  }
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  final List<Widget> _pages = <Widget>[
    const Placeholder(),
    const TestingPage(),
    const UserProfile(),
  ];

  final List<String> _title = [
    'Segnalazioni',
    'Home',
    'Area Personale',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title[_selectedIndex]),
      ),
      body: _pages[_selectedIndex],
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
//return const TestingPage();
  }
}
