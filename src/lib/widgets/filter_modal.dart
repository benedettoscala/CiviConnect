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
  final Function(Map<List, dynamic> criteria) onSubmit;

  /// The initial city to filter by.
  final String startCity;

  /// Whether the city field is enabled.
  final bool isCityEnabled;

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
  const FilterModal({required this.onSubmit, required this.startCity, this.isCityEnabled = true, super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final List<StatusReport> statusCriteria = [];
  final List<PriorityReport> priorityCriteria = [];
  final List<Category> categoryCriteria = [];
  String? cityCriteria;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeManager().customTheme;

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
              Text(
                'Filtra per',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if(widget.isCityEnabled) Text(
                      'Città',
                      style: ThemeManager().customTheme.textTheme.titleMedium,),
                    if(widget.isCityEnabled) _cityField(),
                    const SizedBox(height: 30),
                    Text(
                      'Stato',
                      style: ThemeManager().customTheme.textTheme.titleMedium,
                    ),
                    _getWrap(StatusReport.values, statusCriteria),
                    const SizedBox(height: 16),
                    Text(
                      'Priorità',
                      style: ThemeManager().customTheme.textTheme.titleMedium,
                    ),
                    _getWrap(PriorityReport.values, priorityCriteria),
                    const SizedBox(height: 16),
                    Text(
                      'Categoria',
                      style: ThemeManager().customTheme.textTheme.titleMedium,
                    ),
                    _getWrap(Category.values, categoryCriteria),
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
      name: 'città',
      enabled: enabled ?? true,
      maxLines: 1,
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
