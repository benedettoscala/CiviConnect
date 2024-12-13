import 'package:civiconnect/analisi_dati/analisi_dati_gui.dart';
import 'package:civiconnect/gestione_segnalazione_cittadino/my_segnalazioni_gui.dart';
import 'package:civiconnect/gestione_admin/admin_gui.dart';
import 'package:civiconnect/user_management/user_management_controller.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:civiconnect/user_management/user_profile_gui.dart';
import 'package:flutter/material.dart';

import 'gestione_segnalazione_cittadino/visualizzazione_segnalazioni_gui.dart';
import 'model/users_model.dart';

/// Home page of the application.
class HomePage extends StatefulWidget {
  /// Home page of the application.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  GenericUser? _userInfo;
  bool isLoading = true;
  Map<String, dynamic>? userData;
  late UserManagementController userController;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    userController = UserManagementController(redirectPage: const HomePage());
    late Map<String, dynamic> data;
    try {
      _userInfo = (await UserManagementDAO().determineUserType())!;
      if (_userInfo is Citizen) {
        // if is citizen the home page is this reports view
        _pages[1] = const ReportsViewCitizenGUI();
        data = await userController.getUserData();
      } else {
        data = await userController.getMunicipalityData();
      }
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  final List<Widget> _pages = <Widget>[
    const MyReportsViewGUI(),
    const ReportsViewCitizenGUI(),
    const UserProfile(),
    DataAnalysisGUI(),
    const Placeholder(),
    const UserProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userInfo is Admin) {
      return const AdminHomePage();
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: _pages[
          _userInfo is Municipality ? _selectedIndex + 3 : _selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _userInfo is Citizen
            ? const [
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
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics),
                  label: 'Analisi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment),
                  label: 'Segnalazioni',
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
  }

  PreferredSizeWidget _buildAppBar() {
    if (_selectedIndex == 2) {
      return AppBar(
        title: Text('Area Utente',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        elevation: 10,
        shadowColor: Theme.of(context).shadowColor.withOpacity(0.9),
      );
    }
    return PreferredSize(
      preferredSize: const Size.fromHeight(75),
      child: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        elevation: 10,
        shadowColor: Theme.of(context).shadowColor.withOpacity(0.9),
        title: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                _userInfo != null
                    ? CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(
                          'assets/images/profile/${_userInfo!.uid.hashCode % 6}.jpg',
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(width: 12),
                Text(
                    (userData == null)
                        ? 'Benvenuto Utente'
                        : _userInfo is Citizen
                            ? '${userData?['firstName']} ${userData?['lastName']}'
                            : userData?['municipalityName'],
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary)),
                const Expanded(child: UnconstrainedBox()),
                IconButton(
                  alignment: Alignment.topLeft,
                  icon: Icon(
                    Icons.accessible_forward_sharp,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    // TODO: Implement filter selection method
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
