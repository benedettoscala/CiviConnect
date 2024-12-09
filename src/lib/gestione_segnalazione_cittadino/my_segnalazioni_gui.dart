import 'package:civiconnect/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../widgets/card_widget.dart';
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
    _reportController = CitizenReportManagementController();
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
          child: Text(
              'Nessun dato disponibile. Controlla la tua connessione.'),
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
              // Scrollable list
              _buildReportsList(),
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
          return (_errorText != '')
              ? Text(_errorText)
              : CardWidget(
            report: report,
            onTap: () {
              // TODO: vai alla pagina dei dettagli
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