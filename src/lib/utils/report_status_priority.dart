import 'package:flutter/material.dart';

/// Represents the status of a report.
///
/// This enum categorizes the different statuses a report can have during its lifecycle.
/// Each status has a [name] to display as a string and a [value] used for sorting or comparisons.
enum StatusReport implements Comparable<StatusReport> {
  /// The report is waiting for admin approval.
  waitForVerify(name: 'In verifica', value: 0),

  /// The report has been approved by an admin.
  accepted(name: 'Accettata', value: 1),

  /// The report is being worked on to resolve the issue.
  workingFor(name: 'In lavorazione', value: 2),

  /// The report has been completed.
  completed(name: 'Completata', value: 3);

  /// A human-readable name for the status.
  final String _name;

  /// A numerical value representing the status.
  final int _value;

  /// Constructs a [StatusReport] with a [name] and a [value].
  const StatusReport({required name, required value})
      : _name = name,
        _value = value;

  /// Returns the numerical value associated with the status.
  ///
  /// This value can be used for sorting or comparisons.
  int get value => _value;

  /// Returns the human-readable name of the status.
  ///
  /// This can be used for display purposes.
  String name() => _name;

  @override
  int compareTo(StatusReport other) => value - other.value;
}

/// Represents the priority of a report.
///
/// This enum categorizes the priority levels of a report. Each priority level
/// has a [name], [value], and a [color] associated with it for visual representation.
enum PriorityReport implements Comparable<PriorityReport> {
  /// Low priority level.
  low(value: 0, name: 'Bassa', color: Colors.yellow),

  /// Medium priority level.
  medium(value: 1, name: 'Media', color: Colors.orange),

  /// High priority level.
  high(value: 2, name: 'Alta', color: Colors.red);

  /// A numerical value representing the priority.
  final int _value;

  /// A human-readable name for the priority.
  final String _name;

  /// A color associated with the priority level.
  final Color _color;

  /// Constructs a [PriorityReport] with a [value], [name], and [color].
  const PriorityReport({required value, required name, required color})
      : _value = value,
        _name = name,
        _color = color;

  /// Returns the numerical value associated with the priority.
  ///
  /// This value can be used for sorting or comparisons.
  int get value => _value;

  /// Returns the color associated with the priority level.
  ///
  /// This color can be used for visual representation in the UI.
  Color get color => _color;

  /// Returns the human-readable name of the priority level.
  ///
  /// This can be used for display purposes.
  String get name => _name;

  @override
  int compareTo(PriorityReport other) => _value - other.value;
}