import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/report_model.dart';

/// View of single report details.
class SingleDetailsReport extends StatefulWidget {
  /// Constructs a new `DettagliSegnalazione` instance.
  const SingleDetailsReport(
      {required report, onStateButton, onPriorityButton, super.key})
      : _report = report,
        _onStateButton = onStateButton,
        _onPriorityButton = onPriorityButton;

  final Report _report;
  final void Function()? _onStateButton;
  final void Function()? _onPriorityButton;

  @override
  State<SingleDetailsReport> createState() => _SingleDetailsReportState();
}

class _SingleDetailsReportState extends State<SingleDetailsReport> {
  final _transformationController = TransformationController();

  void _handleDoubleTap(TapDownDetails doubleTapDetails) {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = doubleTapDetails.localPosition;
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
              _statusPriority(context),
              _header(context),
              Container(
                height: 300,
                width: double.infinity,
                child: GestureDetector(
                  onDoubleTapDown: _handleDoubleTap,
                  child: InteractiveViewer(
                      transformationController: _transformationController,
                      panEnabled: true,
                      minScale: 1,
                      boundaryMargin: const EdgeInsets.all(100),
                      maxScale: 2,
                      child: Image.network(
                        widget._report.photo ?? '',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error),
                      )),
                ),
              ),
              _author(context),
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
      margin: const EdgeInsets.only(bottom: 20, left: 5),
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
        ],
      ),
    );
  }

  Widget _author(context) {
    User user = UserManagementDAO().currentUser!;
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : AssetImage(
                    'assets/images/profile/${widget._report.uid.hashCode % 6}.jpg'),
          ),
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

  Widget _statusPriority(context) {
    return Row(
      children: [
        widget._onPriorityButton == null
            ? _priorityCard(context)
            : InkWell(
                onTap: widget._onPriorityButton, child: _priorityCard(context)),
        widget._onStateButton == null
            ? _statusCard(context)
            : InkWell(
                onTap: widget._onStateButton, child: _statusCard(context)),
        _categoryCard(context),
      ],
    );
  }

  Widget _priorityCard(context) {
    return Card(
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
    );
  }

  Widget _categoryCard(context) {
    String category =
        widget._report.category != null ? widget._report.category!.name : 'N/A';
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          category,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  Widget _statusCard(context) {
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(widget._report.status!.name,
            style: Theme.of(context).textTheme.bodySmall),
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
      child: Column(
        children: [
          Text(
            '${widget._report.city!}, ${widget._report.address!.values.toList().join(', ')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Segnalato il: ${dateTime.day}/${dateTime.month}/${dateTime.year}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 50),
              Text(
                  endDate != null
                      ? 'Completato il: ${endDate.day}/${endDate.month}/${endDate.year}'
                      : 'Ancora non completato',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          )
        ],
      ),
    );
  }
}
