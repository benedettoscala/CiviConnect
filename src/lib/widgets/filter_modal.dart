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

  /// Creates a [FilterModal].
  /// Parameters:
  /// - [onSubmit]: The callback function that is triggered when the form is submitted.
  /// - [startCity]: The initial city to filter by.
  /// - [isCityEnabled]: Whether the city field is enabled or not.
  /// - [key]: The key to use for the widget.
  ///
  /// The [onSubmit] and [startCity] parameters are required.
  /// The [isCityEnabled] parameter defaults to `true`.
  /// The [key] parameter is optional.
  ///
  /// The [onSubmit] function should take a map as a parameter,
  /// where the key is the field to filter by and the value is a list of values to filter.
  const FilterModal(
      {required this.onSubmit,
      required this.onReset,
      required this.startCity,
      required this.statusCriteria,
      required this.priorityCriteria,
      required this.categoryCriteria,
      required this.defaultCity,
      this.isCityEnabled = true,
      super.key})
      : startingFilterNumber = statusCriteria.length +
            priorityCriteria.length +
            categoryCriteria.length;

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _cityKey = GlobalKey<FormState>();
  String? _cityTextField;
  int? _filterNumber;

  @override
  void initState() {
    super.initState();
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

    _filterNumber = widget.statusCriteria.length +
        widget.priorityCriteria.length +
        widget.categoryCriteria.length;

    return Wrap(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
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
                      enableFeedback: (_filterNumber == 0 ||
                                  widget.startingFilterNumber == 0) &&
                              widget.defaultCity == _cityTextField
                          ? false
                          : true,
                      elevation: _filterNumber == 0
                          ? null
                          : WidgetStateProperty.all(1),
                      backgroundColor: WidgetStatePropertyAll(_filterNumber == 0
                          ? Colors.transparent
                          : ThemeManager()
                              .customTheme
                              .colorScheme
                              .primaryContainer),
                    ),
                    onPressed: (_filterNumber == 0 ||
                                widget.startingFilterNumber == 0) &&
                            widget.defaultCity == _cityTextField
                        ? null
                        : widget.onReset,
                    child: Text(
                      'Resetta filtri',
                      style: TextStyle(
                        color: (_filterNumber == 0 ||
                                    widget.startingFilterNumber == 0) &&
                                widget.defaultCity == _cityTextField
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
                    Text('Data', style: titleFilterStyle),
                    // TODO DatePicker
                    const SizedBox(height: 16),
                    Text('Stato', style: titleFilterStyle),
                    _getWrap(StatusReport.values, widget.statusCriteria),
                    const SizedBox(height: 16),
                    Text(
                      'Priorità',
                      style: titleFilterStyle,
                    ),
                    _getWrap(PriorityReport.values, widget.priorityCriteria),
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
                      ),
                      onPressed: () => widget.onSubmit(
                        status: widget.statusCriteria,
                        priority: widget.priorityCriteria,
                        category: widget.categoryCriteria,
                        city: _cityTextField ?? widget.startCity,
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
      ],
    );
  }

  Wrap _getWrap(List<dynamic> enumList, List<dynamic> criteria) {
    return Wrap(
      alignment: WrapAlignment.center,
      direction: Axis.horizontal,
      spacing: 10,
      children: [
        for (var el in enumList)
          FilterChip(
            tooltip: 'Filtra per stato ${el.name}',
            label: Text(el.name),
            selected: criteria.contains(el),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  criteria.add(el);
                } else {
                  criteria.remove(el);
                }
              });
            },
          ),
      ],
    );
  }

  FormBuilderTextField _cityField({bool? enabled = true}) {
    return FormBuilderTextField(
      key: _cityKey,
      name: 'città',
      enabled: enabled ?? true,
      maxLines: 1,
      onChanged: (value) {
        setState(() {
          _cityTextField = value;
        });
      },
      initialValue: widget.startCity,
      validator: FormBuilderValidators.required(),
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
