import 'dart:math';

import 'package:civiconnect/model/users_model.dart';
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

class CitizenReportManagementController {
  final Widget redirectPage;

  CitizenReportManagementController({required this.redirectPage});
  final CitizenReportManagementDAO _reportDAO = CitizenReportManagementDAO();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final List<String> imageUrls = [
    'https://drive.google.com/uc?export=view&id=17lSJzFbio_dwt5-uV0udgORdKlMlMpVt',
    'https://drive.google.com/uc?export=view&id=1Q2xMOXpqZWsBwFiGr8uxvztjpu_SejbO',
    'https://drive.google.com/uc?export=view&id=1xfB2i73ywQaYpBqQtFyal006bIzayABD',
    'https://drive.google.com/uc?export=view&id=1K-SdIJUkjQTeY0Xfw4WS6rqwBCctPZtM',
    'https://drive.google.com/uc?export=view&id=1W537VHHIyclsbPeysUJcyhCFX0ne5OA0',
  ];

  String shuffleImages(){
    imageUrls.shuffle(Random());
    return imageUrls[0];
  }
  Future<void> addReport(BuildContext context,
      {required String citta,
      required String titolo,
      required String descrizione,
      required Category categoria,
      required GeoPoint location,
      Map<String, String>? indirizzo}) async {
    Citizen? user = (await UserManagementDAO().determineUserType()) as Citizen?;
    imageUrls.shuffle(Random());
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
      priority: PriorityReport.low,
      authorFirstName: user?.firstName,
      authorLastName: user?.lastName,
      photo: shuffleImages(),
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
      _redirectToLocationPermissionPage(context);
    }
  }

  loc.PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == loc.PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      _redirectToLocationPermissionPage(context);
    }
  }

  if (permissionGranted == loc.PermissionStatus.deniedForever) {
    _redirectToLocationPermissionPage(context);
  }
  return location;
}

Future<GeoPoint?> getCoordinates(BuildContext context) async {
  loc.Location location = await requestLocationPermissions(context);
  loc.LocationData locationData = await location.getLocation();
  return GeoPoint(locationData.latitude!, locationData.longitude!);
  }

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


_redirectToLocationPermissionPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LocationPermissionPage(
        redirectPage: HomePage(),
      ),
    ),
  );
}
