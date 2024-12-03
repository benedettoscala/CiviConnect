import 'package:civiconnect/user_management/user_profile_gui.dart';
import 'package:flutter/material.dart';

/// Home page of the application.
class HomePage extends StatefulWidget {
  /// Home page of the application.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  final List<Widget> _pages = <Widget>[
    Placeholder(),
    Placeholder(),
    UserProfile(),
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
