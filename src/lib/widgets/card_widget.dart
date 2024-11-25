import 'package:flutter/material.dart';

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
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    required this.imageUrl,
    this.onTap,
    super.key,
  });

  /// The name displayed on the card.
  final String name;

  /// A brief description displayed below the name.
  final String description;

  /// The status of the report, represented as a [StatusReport] object.
  final StatusReport status;

  /// The priority of the report, represented as a [PriorityReport] object.
  final PriorityReport priority;

  /// The URL of the image displayed on the card.
  final String imageUrl;

  /// Callback triggered when the card is tapped.
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                /// Left section containing name, status, and description.
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_circle, size: 50),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              name,
                              style: textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _StatusReport(status: status, priority: priority),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          description,
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
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, size: 50, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.65 * 0.65,
          child: Text(
            status.name(),
            style: textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 10),
        Row(
          children: [
            Text(
              priority.name,
              style: textTheme.bodySmall,
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 6,
              backgroundColor: Colors.black26,
              child: CircleAvatar(
                radius: 5,
                backgroundColor: priority.color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
