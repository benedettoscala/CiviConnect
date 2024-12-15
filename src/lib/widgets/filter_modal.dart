import 'package:civiconnect/model/report_model.dart';
import 'package:civiconnect/utils/report_status_priority.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme.dart';

/// A modal dialog that allows the user to filter reports based on various criteria.
class FilterModal extends StatefulWidget {
  /// Callback function that is triggered when the form is submitted.
  final Function(
      {required String city,
      List<StatusReport>? status,
      List<PriorityReport>? priority,
      List<Category>? category,
      DateTimeRange? dateRange,
      bool? isCityEnabled,
      bool? popNav}) onSubmit;

  /// Callback function that is triggered when the form is reset.
  final Function() onReset;

  /// The initial city to filter by.
  final String startCity;

  /// Whether the city field is enabled.
  final bool isCityEnabled;

  /// The criteria to filter by: Status List.
  final List<StatusReport> statusCriteria;

  /// The criteria to filter by: Priority List.
  final List<PriorityReport> priorityCriteria;

  /// The criteria to filter by: Category List.
  final List<Category> categoryCriteria;

  /// The starting filter number.
  final int startingFilterNumber;

  /// The default city. Need for the reset button.
  final String defaultCity;

  /// The date range to filter by.
  final DateTimeRange? dateRange;

  /// Creates a [FilterModal].
  /// Parameters:
  /// - [onSubmit]: The callback function that is triggered when the form is submitted.
  /// - [onReset]: The callback function that is triggered when the form is reset.
  /// - [startCity]: The initial city to filter by.
  /// - [statusCriteria]: The criteria to filter by: Status List.
  /// - [priorityCriteria]: The criteria to filter by: Priority List.
  /// - [categoryCriteria]: The criteria to filter by: Category List.
  /// - [defaultCity]: The default city. Needed for the reset button.
  /// - [dateRange]: The date range to filter by.
  /// - [isCityEnabled]: Whether the city field is enabled or not. Defaults to `true`.
  /// - [key]: The key to use for the widget.
  ///
  const FilterModal(
      {required this.onSubmit,
      required this.onReset,
      required this.startCity,
      required this.statusCriteria,
      required this.priorityCriteria,
      required this.categoryCriteria,
      required this.defaultCity,
      required this.dateRange,
      this.isCityEnabled = true,
      super.key})
      : startingFilterNumber = statusCriteria.length +
            priorityCriteria.length +
            categoryCriteria.length +
            (dateRange != null ? 1 : 0);

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _cityKey = GlobalKey<FormState>();
  late String _cityTextField;
  late int _filterNumber;
  late DateTimeRange? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.dateRange;
    _cityTextField = widget.startCity;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeManager().customTheme;
    final TextStyle titleFilterStyle = ThemeManager()
            .customTheme
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold) ??
        const TextStyle(color: Colors.black, fontWeight: FontWeight.bold);

    /// Calculate the number of filters applied at the beginning.
    _filterNumber = widget.statusCriteria.length +
        widget.priorityCriteria.length +
        widget.categoryCriteria.length;
    _filterNumber = _selectedDate != null ? _filterNumber + 1 : _filterNumber;

    return DraggableScrollableSheet(
        initialChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Filtra per',
                        style: theme.textTheme.titleLarge,
                      ),
                      const Spacer(),
                      TextButton(
                        style: ButtonStyle(
                          enableFeedback:
                              (_isResetButtonEnabled()) ? false : true,
                          elevation: _filterNumber == 0
                              ? null
                              : WidgetStateProperty.all(1),
                          backgroundColor: WidgetStatePropertyAll(
                              _isResetButtonEnabled()
                                  ? Colors.transparent
                                  : ThemeManager()
                                      .customTheme
                                      .colorScheme
                                      .primaryContainer),
                        ),
                        onPressed:
                            (_isResetButtonEnabled()) ? null : widget.onReset,
                        child: Text(
                          'Resetta filtri',
                          style: TextStyle(
                            color: (_isResetButtonEnabled())
                                ? Colors.grey
                                : theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (widget.isCityEnabled)
                          Text(
                            'Città',
                            style: titleFilterStyle,
                          ),
                        if (widget.isCityEnabled) _cityField(),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Data', style: titleFilterStyle),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: IconButton(
                                style: ButtonStyle(
                                  enableFeedback: true,
                                  elevation: WidgetStateProperty.all(3),
                                  backgroundColor: WidgetStatePropertyAll(
                                      ThemeManager()
                                          .customTheme
                                          .colorScheme
                                          .primaryContainer),
                                ),
                                onPressed: () async {
                                  _selectedDate = await _datePickerDialog();
                                },
                                icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedCalendar01,
                                  color: Colors.black54,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                        //DatePickerDialog(firstDate: DateTime.now() , lastDate: DateTime.now()),
                        const SizedBox(height: 16),
                        Text('Stato', style: titleFilterStyle),
                        _getWrap(StatusReport.values, widget.statusCriteria),
                        const SizedBox(height: 16),
                        Text(
                          'Priorità',
                          style: titleFilterStyle,
                        ),
                        _getWrap(
                            PriorityReport.values, widget.priorityCriteria),
                        const SizedBox(height: 16),
                        Text(
                          'Categoria',
                          style: titleFilterStyle,
                        ),
                        _getWrap(Category.values, widget.categoryCriteria),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeManager()
                                .customTheme
                                .colorScheme
                                .primaryContainer,
                            elevation: 2,
                            shadowColor: ThemeManager().customTheme.shadowColor,
                          ),
                          onPressed: () => widget.onSubmit(
                            status: widget.statusCriteria,
                            priority: widget.priorityCriteria,
                            category: widget.categoryCriteria,
                            city: _cityTextField == ''
                                ? widget.startCity
                                : _cityTextField,
                            dateRange: _selectedDate,
                            popNav: true,
                          ),
                          child: const Text('Filtra'),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  /// Creates a [Wrap] widget containing [FilterChip] widgets.
  ///
  /// Parameters:
  /// - [enumList]: The list of enum values to create the [FilterChip] widgets from.
  /// - [criteria]: The list of criteria that are currently selected (should be updated when a [FilterChip] is selected)
  /// It will contain the selected criteria also.
  ///
  /// Returns a [Wrap] widget.
  Wrap _getWrap(List<dynamic> enumList, List<dynamic> criteria) {
    return Wrap(
      alignment: WrapAlignment.center,
      direction: Axis.horizontal,
      spacing: 10,
      runSpacing: 10,
      children: enumList
          .map((el) => FilterChip(
                tooltip: 'Filtra per stato ${el.name}',
                label: Text(el.name),
                selected: criteria.contains(el),
                onSelected: (selected) {
                  /// Check if the enum is in the list of admitted enums.
                  if (!enumList.contains(el)) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            elevation: 5,
                            semanticLabel: 'Errore',
                            titleTextStyle: const TextStyle(fontSize: 15),
                            title: const Text(
                                'Non è possibile filtrare per questa categoria'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('OK'),
                                  ],
                                ),
                              ),
                            ],
                          );
                        });
                    return;
                  }

                  setState(() {
                    if (selected) {
                      criteria.add(el);
                    } else {
                      criteria.remove(el);
                    }
                  });
                },
              ))
          .toList(),
    );
  }

  /// Creates a _datePickerDialog.
  /// Returns a Future<DateTimeRange?> containing the selected date range,
  /// or `null` if the dialog is dismissed.
  Future<DateTimeRange?> _datePickerDialog() {
    return showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      confirmText: 'Conferma',
      errorInvalidRangeText: 'Intervallo non valido',
      errorFormatText: 'Formato non valido',
      fieldStartHintText: 'Inizio',
      fieldEndHintText: 'Fine',
      currentDate: DateTime.now(),
      initialDateRange: _selectedDate,
      locale: const Locale('it', 'IT'),
      helpText: 'Seleziona un intervallo di date',
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: ThemeManager().customTheme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: ThemeManager().customTheme.shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 50,
                    maxHeight: MediaQuery.of(context).size.height - 50,
                  ),
                  child: child,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  /// Returns whether the reset button should be enabled or not as a boolean.
  bool _isResetButtonEnabled() {
    return (_filterNumber == 0 || widget.startingFilterNumber == 0) &&
        widget.defaultCity == _cityTextField;
  }

  /// Creates a [FormBuilderTextField] for the city field.
  /// Parameters:
  /// - The [enabled] parameter is optional and defaults to `true`.
  /// Returns a [FormBuilderTextField] widget.
  FormBuilderTextField _cityField({bool? enabled = true}) {
    return FormBuilderTextField(
      key: _cityKey,
      name: 'città',
      enabled: enabled ?? true,
      maxLines: 1,
      onChanged: (value) {
        setState(() {
          _cityTextField = value ?? '';
        });
      },
      initialValue: widget.startCity,
      validator: FormBuilderValidators.compose(
        [
          FormBuilderValidators.maxLength(255),
          FormBuilderValidators.minLength(0),
        ],
      ),
      decoration: const InputDecoration(
        isDense: true,
        constraints: BoxConstraints(minHeight: 50, maxWidth: 300),
        contentPadding: EdgeInsets.only(top: 15),
        prefixIcon: HugeIcon(
          icon: Icons.location_city,
          color: Colors.grey,
          size: 30,
        ),
        hintText: 'Inserisci la città',
      ),
    );
  }
}
