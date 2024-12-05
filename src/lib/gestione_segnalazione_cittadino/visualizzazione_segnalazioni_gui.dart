import 'package:civiconnect/theme.dart';
import 'package:civiconnect/utils/report_status_priority.dart';
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
  List<Map<String, dynamic>> userData = [];
  bool isLoading = true; // If data are loading
  late ThemeData theme;
  late TextStyle textStyle;
  late GenericUser userInfo;
  late UserManagementDAO userDao;
  late UserManagementController userController;

  @override
  void initState() {
    super.initState();
    theme = ThemeManager().customTheme;
    textStyle = theme.textTheme.titleMedium!.copyWith(fontSize: 16);
    _loadUpdate();
  }

  void _loadUpdate() async {
    CitizenReportManagementController reportController = CitizenReportManagementController();
    userDao = UserManagementDAO();
    userInfo = (await userDao.determineUserType())!;

    try{
      userData = await reportController.getUserReports(userInfo as Citizen) ?? [];
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                            IconButton(onPressed: (){}, icon: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                            IconButton(
                              alignment: Alignment.topLeft,
                              icon: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.onPrimaryContainer),
                              onPressed: () {
                                // TODO: Implement filter selection method
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
          // TODO: go to report creation page
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
      itemCount: reports?.length,
      itemBuilder: (context, index) {
        final report = reports?[index];
        return CardWidget(
          name: report?['authorFirstName'] + ' ' + report?['authorLastName'],
          description: report?['title'],
          status: StatusReport.getStatus(report?['status']) ?? StatusReport.rejected,
          priority: PriorityReport.getPriority(report?['priority']) ?? PriorityReport.unset,
          imageUrl: '',
          onTap: () {
            // TODO go to detail page
          },
        );
      },
    );
  }



}