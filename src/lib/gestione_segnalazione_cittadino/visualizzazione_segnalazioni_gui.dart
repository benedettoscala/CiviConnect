import 'package:civiconnect/model/users_model.dart';
import 'package:civiconnect/theme.dart';
import 'package:civiconnect/utils/report_status_priority.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

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
  late final CitizenReportManagementController _reportController;
  late final ThemeData theme;
  late final TextStyle textStyle;
  late GenericUser? userInfo;

  @override
  void initState() {
    super.initState();
    _reportController = CitizenReportManagementController();
    theme = ThemeManager().customTheme;
    textStyle = theme.textTheme.titleMedium!.copyWith(fontSize: 16);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Errore nel caricamento delle informazioni.')),
          );
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Nessun dato utente disponibile.')),
          );
        }

        final userData = snapshot.data!;
        return _buildScaffold(userData);
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadData() async {
    try {
      userInfo = await _reportController.citizen;
      final userReports = await _reportController.getUserReports();
      return userReports ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Widget _buildScaffold(List<Map<String, dynamic>> userData) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            // Implementa il caricamento aggiuntivo dei dati
          }
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildReportsList(userData),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: vai alla pagina di creazione della segnalazione
        },
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
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
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: 10, horizontal: MediaQuery.of(context).size.width / 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: userInfo != null ? AssetImage('assets/images/profile/${userInfo!.uid.hashCode % 6}.jpg') : const AssetImage('assets/images/profile/0.jpg'),
              ),
              const SizedBox(width: 12),
              Text('Benvenuto', style: textStyle),
              const Expanded(child: UnconstrainedBox()),
              IconButton(
                onPressed: () {},
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                onPressed: () {
                  // TODO: Implementa il metodo di selezione del filtro
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportsList(List<Map<String, dynamic>> userData) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userData.length,
      itemBuilder: (context, index) {
        final report = userData[index];
        return CardWidget(
          uid: report['uid'],
          name: '${report['authorFirstName']} ${report['authorLastName']}',
          description: report['title'],
          status: StatusReport.getStatus(report['status']) ?? StatusReport.rejected,
          priority: PriorityReport.getPriority(report['priority']) ?? PriorityReport.unset,
          imageUrl: '',
          onTap: () {
            // TODO: vai alla pagina dei dettagli
          },
        );
      },
    );
  }
}
