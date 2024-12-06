import 'package:civiconnect/widgets/single_details_report.dart';
import 'package:flutter/material.dart';

import '../model/report_model.dart';
import '../utils/report_status_priority.dart';

/// View of single report details.
class DettagliSegnalazioneComune extends StatefulWidget {
  /// Constructs a new `DettagliSegnalazioneCittadino` instance.
  const DettagliSegnalazioneComune(
      {required report,
      super.key})
      : _report = report;

  final Report _report;
  @override
  State<DettagliSegnalazioneComune> createState() =>
      _DettagliSegnalazioneState();
}

class _DettagliSegnalazioneState extends State<DettagliSegnalazioneComune> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<State> key = GlobalKey();

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
            }),
        onPriorityButton: () => _onChangeValue(
            title: 'Cambia Priorità',
            objectType: PriorityReport.values,
            objectTarget: widget._report,
            onValueSelected: (value) {
              setState(() {
                widget._report.priority = value;
              });
            }));
  }

  // Need only for state and only for priority
  void _onChangeValue<T extends Enum>(
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
}
