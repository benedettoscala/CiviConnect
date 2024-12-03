import 'package:civiconnect/model/users_model.dart';
import 'package:civiconnect/utils/report_status_priority.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing different categories of reports.
enum Category {
  /// Category for waste-related reports.
  waste(name: 'Rifiuti'),

  /// Category for road damage-related reports.
  roadDamage(name: 'Dissesto Stradale'),

  /// Category for maintenance-related reports.
  maintenance(name: 'Manutenzione'),

  /// Category for lighting-related reports.
  lighting(name: 'Illuminazione');

  /// The name of the category.
  final String _name;

  /// Constructs a new `Category` instance.
  ///
  /// [name] is the name of the category.
  const Category({required name}) : _name = name;

  /// Returns the name of the category.
  String name() => _name;
}



/// Class representing a report in the system.
///
/// This class encapsulates the details of a report, including its
/// unique identifier, title, description, associated photo, address,
/// city, status, creation and resolution dates, priority, and author details.
class Report {
  /// The unique identifier of the report.
  final String? reportId;

  /// The unique identifier of the user who created the report.
  final String? uid;

  /// The title of the report.
  final String? title;

  /// The description of the report.
  final String? description;

  /// The photo associated with the report.
  final String? photo;

  /// The address where the report is located.
  final Map<String, String>? address;

  /// The city where the report is located.
  final String? city;

  /// The category of the report.
  final Category? category;

  /// The status of the report.
  final StatusReport? status;

  /// The date when the report was created.
  final Timestamp? reportDate;

  /// The date when the report was resolved or closed.
  final Timestamp? endDate;

  /// The priority level of the report.
  final PriorityReport? priority;

  /// The first name of the author of the report.
  final String? authorFirstName;

  /// The last name of the author of the report.
  final String? authorLastName;

  /// Constructs a new `Report` instance.
  ///
  /// [uid] is the unique identifier of the user who created the report.
  /// [reportId] is the unique identifier of the report.
  /// [title] is the title of the report.
  /// [description] is the description of the report.
  /// [photo] is the photo associated with the report.
  /// [city] is the city where the report is located.
  /// [status] is the status of the report.
  /// [reportDate] is the date when the report was created.
  /// [endDate] is the date when the report was resolved or closed.
  /// [priority] is the priority level of the report.
  /// [authorFirstName] is the first name of the author of the report.
  /// [authorLastName] is the last name of the author of the report.
  /// [address] is the address where the report is located.
  ///
  /// Example:
  /// ```dart
  /// Report report = Report(
  ///   uid: 'user123',
  ///   reportId: 'report456',
  ///   title: 'Pothole on Main Street',
  ///   description: 'There is a large pothole on Main Street that needs to be fixed.',
  ///   photo: 'path/to/photo.jpg',
  ///   city: 'Springfield',
  ///   status: StatusReport.inProgress,
  ///   reportDate: Timestamp.now(),
  ///   endDate: null,
  ///   priority: PriorityReport.high,
  ///   authorFirstName: 'John',
  ///   authorLastName: 'Doe',
  ///   address: {'street': 'Main St', 'number': '123'},
  /// );
  /// ```
  Report({
    required this.uid,
    this.reportId,
    this.title,
    this.description,
    this.photo,
    this.city,
    this.category,
    this.status,
    this.reportDate,
    this.endDate,
    this.priority,
    this.authorFirstName,
    this.authorLastName,
    Map<String, String>? address,
  }) : address = Citizen.validateAddress(address);
}