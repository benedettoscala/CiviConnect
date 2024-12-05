import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'gestione_location_failed.dart';
import '../model/report_model.dart';
import '../utils/report_status_priority.dart';
import 'gestione_segnalazione_cittadino_DAO.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

class CitizenReportManagementController {
  final Widget redirectPage;

  late GeoPoint _location;
  CitizenReportManagementController({required this.redirectPage});
  final CitizenReportManagementDAO _reportDAO = CitizenReportManagementDAO();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> addReport(BuildContext context,
      {required String citta,
      required String titolo,
      required String descrizione,
      required Category categoria,
      required GeoPoint location,
      Map<String, String>? indirizzo}) async {
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
      authorFirstName: '',
      authorLastName: '',
      photo: '',
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

Future<GeoPoint?> getCoordinates(BuildContext context) async {
  final stopwatch = Stopwatch()
    ..start();
  loc.Location location = loc.Location();

  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      stopwatch.stop();
      print('Tempo impiegato: ${stopwatch.elapsedMilliseconds} ms');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LocationPermissionPage(
                  onRetry: () => getCoordinates(context),
                )),
      );
      return null;
    }
  }

  loc.PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == loc.PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      stopwatch.stop();
      print('Tempo impiegato: ${stopwatch.elapsedMilliseconds} ms');
      return null;
    }
  }

  if (permissionGranted == loc.PermissionStatus.deniedForever) {
    stopwatch.stop();
    print('Tempo impiegato: ${stopwatch.elapsedMilliseconds} ms');

    return null;
  }

  loc.LocationData locationData = await location.getLocation();
  return GeoPoint(locationData.latitude!, locationData.longitude!);
}

Future<List<String>> getLocation(GeoPoint location) async {
  final stopwatch = Stopwatch()
    ..start();
  final locationData = location;

//setting posizione
  List<Placemark> placemarks = await placemarkFromCoordinates(
      locationData.latitude!, locationData.longitude!);
  stopwatch.stop();
  print('Tempo impiegato: ${stopwatch.elapsedMilliseconds} ms');
  return [
    placemarks[0].locality ?? "Località non disponibile",
    placemarks[0].street ?? "Strada non disponibile",
    placemarks[0].name ?? "Nome non disponibile"
  ];
}
