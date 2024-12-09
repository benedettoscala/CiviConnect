import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../model/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home_page.dart';
import 'gestione_location_failed.dart';
import '../model/report_model.dart';
import '../utils/report_status_priority.dart';
import 'gestione_segnalazione_cittadino_dao.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';

/// Controller for managing citizen reports.
///
/// This controller handles the initialization of the citizen user and provides
/// methods for adding reports, uploading images, and fetching user reports.
class CitizenReportManagementController {
/// The page to navigate to after certain actions, such as adding a report.
final Widget redirectPage;

  /// Creates a new instance of [CitizenReportManagementController].
  ///
  /// The [redirectPage] parameter specifies the page to navigate to after
  /// certain actions, such as adding a report.
  CitizenReportManagementController({required this.redirectPage}) {
    _loadCitizen();
  }

  final CitizenReportManagementDAO _reportDAO = CitizenReportManagementDAO();
  final UserManagementDAO _userManagementDAO = UserManagementDAO();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Citizen? _citizen;
  final Completer<Citizen> _citizenCompleter = Completer<Citizen>();

/// Adds a new report for the current citizen user.
  ///
  /// This method creates a new report with the provided details and uploads it to the database.
  /// If a photo is provided, it uploads the photo to Firebase Storage and includes the URL in the report.
  /// After successfully adding the report, it navigates to the specified redirect page.
  ///
  /// \param context The build context.
  /// \param citta The city where the report is made.
  /// \param titolo The title of the report.
  /// \param descrizione The description of the report.
  /// \param categoria The category of the report.
  /// \param location The geographical location of the report.
  /// \param indirizzo An optional map containing the address details.
  /// \param photo An optional file containing the photo to be uploaded.
  /// \return A `Future` that resolves to `true` if the report is successfully added, otherwise `false`.
  Future<bool> addReport(BuildContext context,
      {required String citta,
      required String titolo,
      required String descrizione,
      required Category categoria,
      required GeoPoint location,
      Map<String, String>? indirizzo,
      File? photo}) async {
    final report = Report(
      uid: _firebaseAuth.currentUser!.uid,
      city: citta,
      title: titolo,
      description: descrizione,
      category: categoria,
      reportDate: Timestamp.now(),
      address: indirizzo,
      location: location,
      status: StatusReport.inProgress,
      priority: PriorityReport.unset,
      authorFirstName: _citizen?.firstName,
      authorLastName: _citizen?.lastName,
      photo: await _uploadImageToStorage(photo),
      endDate: null,
    );
    final bool result = await _reportDAO.addReport(report);
    if (result) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => redirectPage),
        (route) => false,
      );
    }
    return result;
  }

  Future<String> _uploadImageToStorage(File? image) async {
    if (image == null) {
      return '';
    }

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void _loadCitizen() async {
    try {
      final user = await _userManagementDAO.determineUserType();
      if (user == null) {
        throw Exception('User not logged in');
      }

      if (user is Citizen) {
        _citizen = user;
        _citizenCompleter.complete(user); // Segnala che l'inizializzazione è completa
      } else {
        throw Exception('User is not a citizen');
      }
    } catch (e) {
      _citizenCompleter.completeError('Error determining user type: $e');
    }
  }

  /// Returns the current citizen user.
  Future<Citizen> get citizen async => _citizenCompleter.future;

  /// Fetches the list of reports for a given citizen.
  ///
  /// This method retrieves the list of reports associated with the city of the provided citizen.
  /// If the city is not available, it returns an empty list.
  ///
  /// - [reset]: A `bool` indicating whether to reset the last document retrieved.
  ///   If the [reset] parameter is set to `true`, the method will reset the last document retrieved.
  ///
  /// Returns:
  /// - A [Future] that resolves to a list of maps, where each map contains the report details.
  Future<List<Map<String, dynamic>>?> getUserReports({bool reset = false}) async {
    if (_citizen == null || _citizen!.city == null) {
      return [];
    }

    List<Map<String, dynamic>>? snapshot = await _reportDAO.getReportList(
      city: _citizen!.city!,
      reset: reset,
    );
    return snapshot;
  }

  /* ========================================== BAD WORDS DETECTION ======================================================= */

  /// Downloads the list of bad words from the internet and saves it in the SharedPreferences.
  /// The list is downloaded from url that contains a list of bad words separated by new lines.
  /// The list is saved in the SharedPreferences with the key 'bad_words'.
  /// If the list is already present in the SharedPreferences, it is not downloaded again.
  Future<void> _downloadBadWords() async {
    var box = Hive.box('settings');
    if (box.containsKey('bad_words')) {
      return;
    }
    const url =
        'https://raw.githubusercontent.com/napolux/paroleitaliane/master/paroleitaliane/lista_badwords.txt';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final words = response.body.split('\n')..map((e) => e.trim()).toList();

      var box = Hive.box('settings');
      await box.put('bad_words', words);
    }
  }

  /// Retrieves the list of bad words from the SharedPreferences.
  /// If the list is not present in the SharedPreferences, it is downloaded from the internet.
  Future<List<String>> getBadWords() async {
    var box = Hive.box('settings');
    if (!box.containsKey('bad_words')) {
      await _downloadBadWords();
    }
    return box.get('bad_words', defaultValue: []) as List<String>;
  }

  /// Checks if the given text contains any of the bad words.
  /// The comparison is case-insensitive.
  /// - [text]: The text to check.
  /// - [badWords]: The list of bad words.
  /// Returns:
  /// - `true` if the text contains any of the bad words, `false` otherwise.
  bool containsBadWords(String text, List<String> badWords) {
    for (var word in badWords) {
      if (text.toLowerCase().contains(word.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
}

/// Requests location permissions from the user.
///
/// This function checks if the location service is enabled and if the necessary
/// permissions are granted. If the service is not enabled or the permissions are
/// denied, it redirects the user to the `LocationPermissionPage`.
///
/// \param context The build context.
/// \return A `Future` that resolves to a `loc.Location` object if the permissions
///         are granted and the service is enabled, otherwise `null`.
Future<loc.Location> requestLocationPermissions(BuildContext context) async {
  loc.Location location = loc.Location();

  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      _redirectToPermissionPage(context);
    }
  }

  loc.PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == loc.PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      _redirectToPermissionPage(context);
    }
  }

  if (permissionGranted == loc.PermissionStatus.deniedForever) {
    _redirectToPermissionPage(context);
  }
  return location;
}

/// Retrieves the current coordinates of the user.
///
/// This function requests location permissions from the user and then
/// fetches the current location data. It returns a `GeoPoint` object
/// containing the latitude and longitude of the user's location.
///
/// \param context The build context.
/// \return A `Future` that resolves to a `GeoPoint` object if the location
///         is successfully retrieved, otherwise `null`.
Future<GeoPoint?> getCoordinates(BuildContext context) async {
  loc.Location location = await requestLocationPermissions(context);
  loc.LocationData locationData = await location.getLocation();
  return GeoPoint(locationData.latitude!, locationData.longitude!);
}

/// Retrieves the location details based on the provided [GeoPoint].
///
/// This method fetches the locality, street, and name from the coordinates
/// of the given [GeoPoint] using the geocoding package.
///
/// \param location The geographical location as a [GeoPoint].
/// \return A `Future` that resolves to a list of strings containing the locality,
///         street, and name of the location.
Future<List<String>> getLocation(GeoPoint? location) async {
  final locationData = location;

  //setting posizione
  List<Placemark> placemarks = await placemarkFromCoordinates(
      locationData!.latitude, locationData.longitude);
  return [
    placemarks[0].locality ?? 'Località non disponibile',
    placemarks[0].street ?? 'Strada non disponibile',
    placemarks[0].name ?? 'Nome non disponibile'
  ];
}

// Redirects the user to the LocationPermissionPage.
// This function navigates to the LocationPermissionPage, which prompts the user to enable location services or grant location permissions.
void _redirectToPermissionPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const PermissionPage(
        redirectPage: HomePage(), error: 'Localizzazione disabilitata', icon: Icons.location_off,
      ),
    ),
  );
}