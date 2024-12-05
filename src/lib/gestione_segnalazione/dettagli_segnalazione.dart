import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../model/report_model.dart';

/// View of single report details.
class DettagliSegnalazione extends StatefulWidget {
  /// Constructs a new `DettagliSegnalazione` instance.
  const DettagliSegnalazione({required report, super.key}) : _report = report;

  final Report _report;

  @override
  State<DettagliSegnalazione> createState() => _DettagliSegnalazioneState();
}

class _DettagliSegnalazioneState extends State<DettagliSegnalazione> {
  final _transformationController = TransformationController();
  late TapDownDetails _doubleTapDetails;

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(2.5);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli Segnalazione'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _header(context),
              Container(
                height: 300,
                width: double.infinity,
                child: GestureDetector(
                  onDoubleTapDown: (d) => _doubleTapDetails = d,
                  onDoubleTap: _handleDoubleTap,
                  child: InteractiveViewer(
                      transformationController: _transformationController,
                      panEnabled: true,
                      minScale: 1,
                      boundaryMargin: const EdgeInsets.all(100),
                      maxScale: 2,
                      // TODO: capire come mettere le immagini su firebase.
                      child: Image.network('',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      )),
                ),
              ),
              _author(context),
              _status(context),
              _descriptionText(context),
              _footer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(
    context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              widget._report.title!,
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              softWrap: false,
            ),
          ),
          Card(
            elevation: 0.5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.black26,
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: widget._report.priority!.color,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget._report.priority!.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _author(context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          const Icon(Icons.account_circle, size: 50),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              '${widget._report.authorFirstName!} ${widget._report.authorLastName!}',
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _status(context) {
    return Container(
      alignment: Alignment.centerRight,
      child: Card(
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(widget._report.status!.name()),
        ),
      ),
    );
  }

  Widget _descriptionText(context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget._report.description!,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),
    );
  }

  Widget _footer(context) {
    final DateTime dateTime = widget._report.reportDate!.toDate();
    final DateTime? endDate = widget._report.endDate?.toDate();

    if (kDebugMode) {
      print(widget._report.address!.keys);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${widget._report.city!}, ${widget._report.address!.values.toList().join(', ')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text('${dateTime.day}/${dateTime.month}/${dateTime.year}',
              style: Theme.of(context).textTheme.bodySmall),
          Text(
              endDate != null
                  ? '${endDate.day}/${endDate.month}/${endDate.year}'
                  : 'Ancora non completato',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
