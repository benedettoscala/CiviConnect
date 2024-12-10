import 'package:flutter/material.dart';

import '../model/report_model.dart';
import '../utils/report_status_priority.dart';

/// A custom widget that displays a card with user details, status, priority, and an image.
///
/// This widget is designed to show a user's name, description, status, priority level,
/// and an image. It is also tappable, with a customizable `onTap` callback.
class CardWidget extends StatelessWidget {
  /// Creates a custom card widget.
  ///
  /// The [name], [description], [status], [priority], and [imageUrl] parameters are required.
  /// The [onTap] is optional.
  const CardWidget({
    required report,
    this.onTap,
    super.key,
  }) : _report = report;

  /// keep the report object
  final Report _report;

  /// Callback triggered when the card is tapped.
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      /// Left section containing name, status, and description.
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage(
                                      'assets/images/profile/${_report.uid.hashCode % 6}.jpg'),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${_report.authorFirstName} ${_report.authorLastName}',
                                    style: textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _report.description!,
                                style: textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Right section containing the image.
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _report.photo ?? '',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 100,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _StatusReport(
                      status: _report.status ?? StatusReport.underReview,
                      priority: _report.priority ?? PriorityReport.unset),
                ],
              )),
        ),
      ),
    );
  }
}

/// A widget that displays the status and priority of a report.
///
/// This widget is used inside the [CardWidget] to show the report's current
/// status and priority level with a corresponding color indicator.
class _StatusReport extends StatelessWidget {
  /// Creates a widget to display the report's status and priority.
  const _StatusReport({
    required this.status,
    required this.priority,
  });

  /// The priority of the report.
  final PriorityReport priority;

  /// The status of the report.
  final StatusReport status;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Card(
          elevation: 0.5,
          color: Colors.white70,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 6,
                  backgroundColor: Colors.black26,
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: priority.color,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  priority.name,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 7.5),
        Card(
          elevation: 0.5,
          color: Colors.white70,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Text(
              status.name,
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
