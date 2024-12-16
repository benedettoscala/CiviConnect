import 'dart:convert';

import 'package:civiconnect/gestione_segnalazione_cittadino/dettagli_segnalazione_cittadino_gui.dart';
import 'package:civiconnect/gestione_segnalazione_cittadino/inserimento_segnalazione_gui.dart';
import 'package:civiconnect/home_page.dart';
import 'package:civiconnect/model/users_model.dart';
import 'package:civiconnect/theme.dart';
import 'package:civiconnect/utils/report_status_priority.dart';
import 'package:civiconnect/utils/snackbar_riscontro.dart';
import 'package:civiconnect/widgets/filter_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
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
  Citizen? _citizen;
  int _numberOfFilters = 0;
  final List<StatusReport> _statusCriteria = [];
  final List<PriorityReport> _priorityCriteria = [];
  final List<Category> _categoryCriteria = [];
  String? _keyWords;
  String? _citySelected;
  DateTimeRange? _dateRange;
  final Set<String> _cities = {};

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
    _reportController =
        CitizenReportManagementController(redirectPage: const HomePage());
    theme = ThemeManager().customTheme;
    _loadInitialData(); // Load initial data
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Libera il controller dello scroll
    super.dispose();
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

  /* ----------------- DATA LOADING ----------------- */

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
        _citizen = value;
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
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  /* ----------------- SCAFFOLD ----------------- */

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
                          'Nessuna segnalazione trovata',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    )
                  :

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
                builder: (context) => InserimentoSegnalazioneGUI()),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  /* ----------------- WIDGETS ----------------- */

  /// Builds the header of the page
  /// Contains the user profile picture and the search and filter buttons
  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            /// Search bar
            Expanded(child: _searchBar()),

            /// Filter button
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                color: _numberOfFilters > 0
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.5),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /// Filter Button
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.filter_list,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            onPressed: () {
                              /// Show the filter modal
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => _citizen != null
                                      ? FilterModal(
                                          dateRange: _dateRange,
                                          defaultCity: _citizen?.city ?? '',
                                          categoryCriteria: _categoryCriteria,
                                          statusCriteria: _statusCriteria,
                                          priorityCriteria: _priorityCriteria,
                                          startCity: _citySelected ??
                                              (_citizen?.city ?? ''),
                                          onSubmit: _filterData,
                                          onReset: _resetFilters,
                                        )
                                      : const SizedBox());
                            },
                          ),

                          /// Show the number of filters applied if there are any
                          if (_numberOfFilters > 0)
                            Positioned(
                              right: -5,
                              top: -5,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.red,
                                child: Text(
                                  _numberOfFilters.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        Text('Segnalazioni per ${_citySelected ?? (_citizen?.city ?? '')}',
            style: theme.textTheme.titleMedium),
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
            endDate: report['endDate'],
            address: report['address'] == null
                ? {'street': 'N/A', 'number': 'N/A'}
                : {
                    'street': report['address']['street'] ?? 'N/A',
                    'number': report['address']['number'] ?? 'N/A',
                  },
            city: report['city'],
            photo: report['photo'],
            category: Category.getCategory(report['category']),
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
                onPressed: () {
                  if (_keyWords != null && _keyWords!.isNotEmpty ||
                      _numberOfFilters > 0) {
                    _filterData(
                        city: _citizen?.city ?? '', keyWords: _keyWords);
                  }
                },
              ),
              Flexible(
                child: TextField(
                  decoration: const InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Cerca segnalazione...'),
                  onChanged: (value) {
                    _keyWords = value;
                  },
                  onSubmitted: (value) {
                    if(value.length >255) { //prova
                      _errorText='Lunghezza search deve essere inferiore a 255';
                    }
                    if (value.isNotEmpty || _numberOfFilters > 0) {
                      _filterData(
                          city: _citizen?.city ?? '', keyWords: _keyWords);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ----------------- METHODS TO CONTROLLER AND UTILITY METHODS ----------------- */

  /// Refreshes the data when the user performs a pull-to-refresh action.
  ///
  /// This method reloads the initial data and waits for a short delay before completing.
  Future<void> _pullRefresh() async {
    _loadInitialData();
    _categoryCriteria.clear();
    _statusCriteria.clear();
    _priorityCriteria.clear();
    setState(() {
      _dateRange = null;
      _numberOfFilters = 0;
      _keyWords = '';
      _errorText = '';
      _citySelected = _citizen?.city;
    });
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Filters the data based on the selected filters.
  /// Parameters:
  /// - status: The list of selected status filters.
  /// - priority: The list of selected priority filters.
  /// - category: The list of selected category filters.
  /// - city: The city to filter the reports by.
  /// This method fetches the reports based on the selected filters and updates the state with the new data.
  /// If an error occurs during the filtering process, the error message is displayed.
  Future<void> _filterData(
      {String? city,
      List<StatusReport>? status,
      List<PriorityReport>? priority,
      List<Category>? category,
      String? keyWords,
      DateTimeRange? dateRange,
      bool?
          isCityEnabled, // Not used in this method but required for the method signature
      bool? popNav = false}) async {
    _numberOfFilters = 0;
    _numberOfFilters += status?.length ?? 0;
    _numberOfFilters += priority?.length ?? 0;
    _numberOfFilters += category?.length ?? 0;
    _numberOfFilters += dateRange != null ? 1 : 0;

    setState(() {
      _isLoading = true;
      _hasMoreData = true;
      _errorText = '';
      _dateRange = dateRange;
    });

    try {
      _reportController.citizen.then((value) async {
        _citizen = value;

        if (await _checkValidity(city ?? '')) {
          _citySelected = city;
        } else {
          _citySelected = _citizen!.city;
          showMessage(context, isError: true, message: 'Città non valida');
          return null;
        }

        _reportController
            .filterReportsBy(
                city: city ?? '',
                status: status,
                priority: priority,
                category: category,
                dateRange: dateRange,
                keyword: keyWords)
            .then((value) async {
          _userData.clear();

          if (mounted) {
            setState(() {
              if (value != null && value.isNotEmpty) {
                _userData.addAll(value);
              } else {
                _errorText = 'Nessuna segnalazione trovata';
              }
            });
          }
        });
      });
    } catch (e) {
      _errorText = 'Errore durante il caricamento filtrato: $e';
    } finally {
      if (popNav!) {
        Navigator.pop(context);
      }
      setState(() {
        _isLoading = false;
        _hasMoreData = false;
      });
    }
  }

  /// Resets the filters and reloads the initial data.
  /// This method resets the filters and reloads the initial data.
  void _resetFilters() async {
    Navigator.pop(context);
    await _pullRefresh();
  }

  /// Loads the list of municipalities.
  /// This method loads the list of municipalities from a JSON file.
  /// Returns:
  /// - A list of strings containing the names of the municipalities.
  Future<List<String>> _loadMunicipalities() async {
    String data = await rootBundle
        .loadString('assets/files/comuni-localita-cap-italia.json');
    Map<String, dynamic> jsonResult = json.decode(data);

    List<dynamic> municipalitiesList =
        jsonResult['Sheet 1 - comuni-localita-cap-i'];
    List<String> allMunicipalities = municipalitiesList
        .map((comune) => comune['Comune Localita’'].toString())
        .toSet()
        .toList();

    return allMunicipalities;
  }

  /// Checks if the city is valid.
  /// This method checks if the city is valid by comparing it to a list of valid cities.
  /// Parameters:
  /// - city: The city to check.
  /// Returns:
  /// - A boolean value indicating whether the city is valid.
  Future<bool> _checkValidity(String city) async {
    if (_cities.isEmpty) {
      List<String> municipalities = await _loadMunicipalities();
      _cities.addAll(municipalities.map((e) => e.toLowerCase()));
    }

    return _cities.contains(city.toLowerCase());
  }
}
