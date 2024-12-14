import 'package:civiconnect/widgets/single_details_report.dart';
import 'package:flutter/material.dart';

import '../model/report_model.dart';
import '../utils/report_status_priority.dart';
import 'gestione_segnalazione_comune_controller.dart';

/// View of single report details.
class DettagliSegnalazioneComune extends StatefulWidget {
  /// Constructs a new `DettagliSegnalazioneCittadino` instance.
  const DettagliSegnalazioneComune({required report, super.key})
      : _report = report;

  final Report _report;

  @override
  State<DettagliSegnalazioneComune> createState() =>
      _DettagliSegnalazioneState();
}

List<StatusReport> _filteredStatusValues(StatusReport currentStatus) {
  switch (currentStatus) {
    case StatusReport.underReview:
      return StatusReport.values.sublist(0);
    case StatusReport.accepted:
      return StatusReport.values.sublist(1);
    case StatusReport.inProgress:
      return StatusReport.values.sublist(2);
    case StatusReport.completed:
      return StatusReport.values.sublist(3);
    case StatusReport.rejected:
      return StatusReport.values.sublist(4);
  }
}

class _DettagliSegnalazioneState extends State<DettagliSegnalazioneComune> {
  void _saveReportState(StatusReport oldStatus) {
    // Implement the logic to save the current state of the report
    MunicipalityReportManagementController(context: context).editReportStatus(
      city: widget._report.city!,
      reportId: widget._report.reportId!,
      newStatus: widget._report.status!,
      currentStatus: oldStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleDetailsReport(
        report: widget._report,
        onStateButton: () => _onChangeValue(
              title: 'Cambia Stato',
              objectType: StatusReport.values,
              objectTarget: widget._report,
              onValueSelected: (value) {
                setState(() {
                  widget._report.status = value;
                });
              },
              clickableValues: _filteredStatusValues(widget._report.status!),
            ),
        onPriorityButton: () => onChangeValue(
              title: 'Cambia Priorità',
              objectType: PriorityReport.values.where((value) => value != PriorityReport.unset).toList(),
              objectTarget: widget._report,
              onValueSelected: (value) {
                //implement showMessage if it works
                MunicipalityReportManagementController().editReportPriority(
                    city: widget._report.city!,
                    reportId: widget._report.reportId!,
                    newPriority: value);
                setState(() {
                  widget._report.priority = value;
                });
              },
            ));
  }

  // Need only for priority
  void onChangeValue<T extends Enum>(
      {required String title,
      required List<T> objectType,
      required Report objectTarget,
      required void Function(T) onValueSelected}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                  child: ListBody(
                children: objectType.map((value) {
                  return ListTile(
                    title: Text(value.toString()),
                    onTap: () {
                      onValueSelected(value);
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              )));
        });
  }

  // Need only for state
  void _onChangeValue<T extends Enum>({
    required String title,
    required List<T> objectType,
    required Report objectTarget,
    required void Function(T) onValueSelected,
    required List<T> clickableValues,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        // Save the current state of the report
        final oldStatusLocal = objectTarget.status as StatusReport;
        T? selectedValue = objectTarget.status as T;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: ListBody(
                  children: objectType.map((value) {
                    return ListTile(
                      title: Text(value.toString()),
                      enabled: clickableValues.contains(value),
                      selected: selectedValue == value,
                      onTap: clickableValues.contains(value)
                          ? () {
                              setState(() {
                                selectedValue = value;
                              });
                              onValueSelected(value);
                              //Navigator.of(context).pop();
                            }
                          : null,
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annulla'),
                ),
                TextButton(
                  onPressed: () {
                    // Implement the logic for the confirm action
                    _saveReportState(oldStatusLocal);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Aggiorna'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
