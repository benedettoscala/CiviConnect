import 'package:civiconnect/widgets/single_details_report.dart';
import 'package:flutter/material.dart';

import '../model/report_model.dart';

/// View of single report details.
class DettagliSegnalazioneCittadino extends StatefulWidget {
  /// Constructs a new `DettagliSegnalazioneCittadino` instance.
  const DettagliSegnalazioneCittadino({required report, super.key})
      : _report = report;

  final Report _report;

  @override
  State<DettagliSegnalazioneCittadino> createState() =>
      _DettagliSegnalazioneState();
}

class _DettagliSegnalazioneState extends State<DettagliSegnalazioneCittadino> {
  @override
  Widget build(BuildContext context) {
    return SingleDetailsReport(report: widget._report);
  }
}
