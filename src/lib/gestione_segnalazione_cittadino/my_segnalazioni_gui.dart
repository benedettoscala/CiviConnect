import 'package:civiconnect/theme.dart';
import 'package:flutter/material.dart';
import '../model/report_model.dart';
import '../utils/report_status_priority.dart';
import '../widgets/card_widget.dart';
import 'dettagli_segnalazione_cittadino_gui.dart';
import 'gestione_segnalazione_cittadino_controller.dart';

/// A widget that displays the user's reports.
///
/// This widget is a stateful widget that manages the state of the user's reports
/// and provides functionality to load and display the reports.
class MyReportsViewGUI extends StatefulWidget {
  /// Constructor of [MyReportsViewGUI]
  const MyReportsViewGUI({super.key});

  @override
  State<MyReportsViewGUI> createState() => _MyReportsListState();
}

class _MyReportsListState extends State<MyReportsViewGUI> {
  late final CitizenReportManagementController _reportController;
  late final ThemeData theme;
  late final List<Map<String, dynamic>> _userData = [];
  bool _hasMoreData = true;
  bool _isLoading = true;
  String _errorText = '';

  /// Initializes the state of the widget.
  ///
  /// This method sets up the scroll controller, initializes the report controller,
  /// and loads the initial data.
  @override
  void initState() {
    super.initState();
    _reportController = CitizenReportManagementController(redirectPage: const MyReportsViewGUI());
    theme = ThemeManager().customTheme;
    _loadInitialData(); // Load initial data
  }

  /// Build the widget
  /// If there are no data to load, shows a message
  /// If there is an error, shows an error message
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _hasMoreData
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : const Scaffold(
              body: Center(child: Text('Fine.')),
            );
    }

    if (_userData.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Nessun dato disponibile. Controlla la tua connessione.'),
        ),
      );
    }
    return _buildScaffold();
  }

  /// Loads the initial data for the widget.
  ///
  /// This method fetches the current citizen user and their reports,
  /// and updates the state with the retrieved data.
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _hasMoreData = true;
    });
    try {
      _reportController.citizen.then((value) {
        _reportController.getMyReports(reset: true).then((value) {
          _userData.clear();
          setState(() {
            if (value != null && value.isNotEmpty) {
              _userData.addAll(value);
            } else {
              _hasMoreData = false;
            }
            _isLoading = false;
          });
        });
      });
    } catch (e) {
      _errorText = 'Errore durante il caricamento iniziale: $e';
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Builds the scaffold of the page
  Widget _buildScaffold() {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: CustomScrollView(
            slivers: [
              // Scrollable list
              _buildReportsList(),
            ],
          ),
        ),
      ),
    );
  }

  /// Main Body of the page
  /// Contains the list of reports
  Widget _buildReportsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: _userData.length + 1,
            (context, index) {
          if (index == _userData.length) {
            // Mostra un indicatore di caricamento alla fine della lista
            return (_isLoading)
                ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
                : const SizedBox(height: 0);
          }
          final report = _userData[index];
          Report store = Report(
              reportId: report['reportId'],
              title: report['title'],
              uid: report['uid'],
              authorFirstName: '${report['authorFirstName']}',
              authorLastName: '${report['authorLastName']}',
              description: report['title'],
              status: StatusReport.getStatus(report['status']) ??
                  StatusReport.rejected,
              priority: PriorityReport.getPriority(report['priority']) ??
                  PriorityReport.unset,
              reportDate: report['reportDate'],
              address: report['address'] == null
                  ? {'street': 'N/A', 'number': 'N/A'}
                  : {
                'street': report['address']['street'] ?? 'N/A',
                'number': report['address']['number'] ?? 'N/A',
              },
              city: report['city'],
              photo: report['photo']
          );
          return (_errorText != '')
              ? Text(_errorText)
              : CardWidget(
            report: store,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DettagliSegnalazioneCittadino(report: store)));
            },
          );
        },
      ),
    );
  }

  /// Refreshes the data when the user performs a pull-to-refresh action.
  ///
  /// This method reloads the initial data and waits for a short delay before completing.
  Future<void> _pullRefresh() async {
    _loadInitialData();
    await Future.delayed(const Duration(seconds: 1));
  }
}
