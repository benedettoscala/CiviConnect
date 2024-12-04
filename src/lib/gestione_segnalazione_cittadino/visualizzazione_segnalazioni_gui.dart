import 'package:civiconnect/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../model/users_model.dart';
import '../user_management/user_management_controller.dart';
import '../user_management/user_management_dao.dart';
import '../widgets/card_widget.dart';
import 'gestione_segnalazione_cittadino_controller.dart';

/// Gui to visualize reports list of citizen city
class ReportsViewCitizenGUI extends StatefulWidget {
  /// Constructor of [ReportsViewCitizenGUI]
  const ReportsViewCitizenGUI({super.key});

  @override
  State<ReportsViewCitizenGUI> createState() => _ReportsListCitizenState();
}

class _ReportsListCitizenState extends State<ReportsViewCitizenGUI> {

  // Variable State
  bool isEditing = false;
  Map<String, dynamic> userData = {};
  bool isLoading = true; // If data are loading
  late ThemeData theme;
  late TextStyle textStyle;
  late GenericUser userInfo;
  late UserManagementController userController;

  @override
  void initState() {
    super.initState();
    theme = ThemeManager().customTheme;
    textStyle = theme.textTheme.titleMedium!.copyWith(fontSize: 16);
    _loadUpdate();
  }

  void _loadUpdate() async {
    userInfo = (await UserManagementDAO().determineUserType())!;
    /*late Map<String, dynamic> data;
    try {
      userInfo = (await UserManagementDAO().determineUserType())!;
      if (userInfo is Citizen) {
        data = await userController.getUserData();
      } else {
        setState(() {
          isLoading = false;
        });
      }
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    } */
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: MediaQuery.of(context).size.width / 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage('assets/images/profile/${userInfo.uid.hashCode % 6}.jpg')
                            ),
                            const SizedBox(width: 12),
                            Text('Benvenuto', style: Theme.of(context).textTheme.titleMedium),
                            const Expanded(child: UnconstrainedBox()),
                            IconButton(onPressed: (){}, icon: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: Theme.of(context).colorScheme.onPrimaryContainer))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              IconButton(
                alignment: Alignment.topLeft,
                icon: Icon(Icons.filter_list_alt, color: Theme.of(context).colorScheme.onPrimaryContainer),
                onPressed: () {
                  // TODO: Implement filter selection method
                },
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              // [ReportsList
              if (userData.isNotEmpty)
                FutureBuilder<Widget>(
                  future: _buildReportsList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('Errore nel caricamento delle segnalazioni.');
                    } else {
                      return snapshot.data!;
                    }
                  },
                )
              else
                  const Text('Nessun dato utente disponibile.')
            ],
          )
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement action for the button
        },
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  Future<Widget> _buildReportsList() async {
    // Example data, replace with actual data fetching logic
    final reports = await CitizenReportManagementController().getUserReports(userInfo as Citizen);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return CardWidget(
          name: report['name'],
          description: report['title'],
          status: report['status'],
          priority: report['priority'],
          imageUrl: '',
          onTap: () {
            // Handle card tap
          },
        );
      },
    );
  }



}