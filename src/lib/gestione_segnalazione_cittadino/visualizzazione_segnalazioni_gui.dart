import 'dart:math';

import 'package:civiconnect/gestione_segnalazione_cittadino/inserimento_segnalazione_gui.dart';
import 'package:civiconnect/home_page.dart';
import 'package:civiconnect/gestione_segnalazione_cittadino/dettagli_segnalazione_cittadino_gui.dart';
import 'package:civiconnect/theme.dart';
import 'package:civiconnect/utils/report_status_priority.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hugeicons/hugeicons.dart';

import '../model/report_model.dart';
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
  late final List<Map<String, dynamic>> _userData = [];
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _isLoading = true;
  String _errorText = '';
  late ScrollController _scrollController;

  /// Initializes the state of the widget.
  ///
  /// This method sets up the scroll controller, initializes the report controller,
  /// and loads the initial data.
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent &&
            _hasMoreData &&
            !_isLoadingMore) {
          _loadUpdateData();
        }
      });
    _reportController = CitizenReportManagementController(redirectPage: const HomePage());
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
        _reportController.getUserReports(reset: true).then((value) {
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

  /// Loads additional data when the user scrolls to the bottom of the list.
  ///
  /// This method fetches more reports from the controller and updates the state
  /// with the new data.
  void _loadUpdateData() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoadingMore = true;
      });
    });

    if (_isLoadingMore || !_hasMoreData) {
      return;
    }

    try {
      /// Implements loading of new data: fetch data from the controller
      /// and add it to the list of data
      /// If no data is returned, set hasMoreData to false
      _reportController.getUserReports().then((value) {
        SchedulerBinding.instance.addPostFrameCallback((_) async {
          setState(() {
            if (value == null || value.isEmpty) {
              _hasMoreData = false;
            } else {
              _userData.addAll(value);
            }
          });
        });
      });

      /// Error handling: set hasMoreData to false and hasError to true to show error message
    } catch (e) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        setState(() {
          _hasMoreData = false;
          _errorText = e.toString();
        });
      });

      /// Set isLoadingMore to false to allow loading more data if needed
    } finally {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        setState(() {
          _isLoadingMore = false;
        });
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
            controller: _scrollController, // Added scroll controller
            slivers: [
              // Non scrollable Header
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              (_userData.isEmpty)
                    // Check if there are any reports to show
                    // Show a message if there are no reports
                  ? SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Nessuna segnalazione trovata.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ) :

                  /// Show the list of reports if there are any
                  // Scrollable list
                  _buildReportsList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Send to the report creation page
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const InserimentoSegnalazioneGUI()),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  /// Builds the header of the page
  /// Contains the user profile picture and the search and filter buttons
  Widget _buildHeader() {
    return Row(
  children: [
    /// Search bar
    Expanded(child: _searchBar()),

    /// Filter button
    Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Colors.white70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
    )
  ],
);
  }

  /// Main Body of the page
  /// Contains the list of reports
  Widget _buildReportsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: _userData.length + (_hasMoreData ? 1 : 0),
        (context, index) {
          if (index == _userData.length) {
            // Mostra un indicatore di caricamento alla fine della lista
            _loadUpdateData();
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
            description: report['description'],
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
                              DettagliSegnalazioneCittadino(report: store)),
                    );
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

  /// Builds the search bar
  /// /// Builds the search bar widget.
  ///
  /// This widget contains a search icon and a text field for searching reports.
  /// The search icon does not have any functionality implemented yet.
  Widget _searchBar() {
    return Padding(
  padding: const EdgeInsets.all(10.0),
  child: Card(
    color: Colors.white70,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.5),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(
              HugeIcons.strokeRoundedSearch02,
              size: 24,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            onPressed: () { // TODO - Implement search functionality
            },
          ),
          const Flexible(
            child: TextField(
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Cerca segnalazione...'),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
