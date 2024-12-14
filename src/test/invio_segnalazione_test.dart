import 'dart:io';

import 'package:civiconnect/firebase_options.dart';
import 'package:civiconnect/gestione_segnalazione_cittadino/gestione_segnalazione_cittadino_controller.dart';
import 'package:civiconnect/gestione_segnalazione_cittadino/inserimento_segnalazione_gui.dart';
import 'package:civiconnect/model/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

class FakeInserimentoSegnalazioneController extends Fake
    implements CitizenReportManagementController {
  @override
  Future<bool> addReport(BuildContext context,
      {required String citta,
      required String titolo,
      required String descrizione,
      required Category categoria,
      required GeoPoint location,
      Map<String, String>? indirizzo,
      File? photo}) {
    if (titolo.length <=
            255 /*&& descrizione.length <= 1023
        && (categoria == Category.getCategory("Rifiuti") ||
            categoria == Category.getCategory("Dissesto Stradale")
            || categoria == Category.getCategory("Manutenzione") ||
            categoria == Category.getCategory("Illuminazione"))
        && location.latitude != 0 && location.longitude != 0 &&
        indirizzo!['address'] != ''
        && indirizzo['city'] != '' && photo!.path.endsWith('.jpg')*/
        ) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }
}

@GenerateMocks([CitizenReportManagementController])
void main() {
  ///Test Case TC_1.0_1
  _testDescription(
      description: 'TC_1.0_1',
      input: '',
      expected: 'Value must have a length less than or equal to 1023',
      reason: 'Description field must respect length constraints');
/*
    ///Test Case TC_1.0_2
    _testTitle(
        description: 'TC_1.0_2',
        input: '',
        expected: 'Value must have a length less than or equal to 255',
        reason: 'Title field must respect length constraints');

    ///Test Case TC_1.0_3
    _testCategory(
        description: 'TC_1.0_3',
        input: 'Buche',
        expected:
        'Value must be ‘Rifiuti’ OR ‘Dissesto stradale’ OR ‘Manutenzione’ OR ‘Illuminazione',
        reason: 'Category field must have a valid category');

    /// Test Case TC_1.0_4
    _testValidation(
        description: 'TC_1.0_4',
        input: '',
        //GeoPoint(0, 0),
        expected: 'Invalid coordinates',
        isValid: false,
        reason: 'Location field must have valid coordinates');

    /// Test Case TC_1.0_5
    _testValidation(
        description: 'TC_1.0_5',
        input: '',
        //{'address': '', 'city': ''},
        expected: 'Coordinates value must be setted',
        isValid: false,
        reason: 'Address field must have valid address');

    /// Test Case TC_1.0_6
    _testValidation(
        description: 'TC_1.0_6',
        input: 'image.png',
        expected: 'Invalid file extension',
        isValid: false,
        reason: 'Photo field must have valid file extension');

    /// Test Case TC_1.0_7
    _testValidation(
      description: 'TC_1.0_7',
      input: 'image.jpg',
      expected: 'Valid photo',
      isValid: true,
      reason: 'Photo field must have valid file extension',
    );*/
}

void _testDescription(
    {required String description,
    required String input,
    required String expected,
    String? reason}) {
  testWidgets('Report Description: $description', (tester) async {
    // Load Insert Report Widget and Test Environment
    await _pumpWidgetAndTestEnv(tester: tester);
    // Insert text in the description field
    await tester.enterText(find.byKey(const Key('Descrizione')), input);
    // Tap the send button and trigger a frame.
    await tester.tap(find.text('Invia'));
    await tester.pump();

    // Get form field keys where error messages are saved
    List<GlobalKey<FormBuilderFieldState>> keys = _getFieldKeys();

    //Test expected error message
    expect(keys[0].currentState?.errorText, expected, reason: reason);
    //'Il valore inserito deve avere una lunghezza minore o uguale a 255.'
  });
}

void _testTitle(
    {required String description,
    required String input,
    required String expected,
    String? reason}) {
  testWidgets('Report Title: $description', (tester) async {
    // Load Insert Report Widget and Test Environment
    await _pumpWidgetAndTestEnv(tester: tester);

    // Insert text in the title field
    await tester.enterText(find.byKey(const Key('Titolo')), input);
    // Tap the send button and trigger a frame.
    await tester.tap(find.text('Invia'));
    await tester.pump();
  });
}

void _testCategory(
    {required String description,
    required String input,
    required String expected,
    String? reason}) {
  testWidgets('Report Category: $description', (tester) async {
    // Load Insert Report Widget and Test Environment
    await _pumpWidgetAndTestEnv(tester: tester);

    // Insert text in the category field
    await tester.enterText(find.byKey(const Key('Categoria')), input);
    // Tap the send button and trigger a frame.
    await tester.tap(find.text('Invia'));
    await tester.pump();
  });
}

void _testValidation(
    {required String description,
    required String input,
    required String expected,
    required bool isValid,
    String? reason}) {
  testWidgets('Report Validation: $description', (tester) async {
    // Load Insert Report Widget and Test Environment
    await _pumpWidgetAndTestEnv(tester: tester);

    // Insert text in the photo field
    await tester.enterText(find.byKey(const Key('Foto')), input);
    // Tap the send button and trigger a frame.
    await tester.tap(find.text('Invia'));
    await tester.pump();
  });
}

Future<void> _pumpWidgetAndTestEnv(
    {required WidgetTester tester,
    CitizenReportManagementController? controller}) async {
  // Load Insert Report Widget
  await tester.pumpWidget(MaterialApp(
      home: InserimentoSegnalazioneGUI(
    controller: controller,
  )));
  await tester.pumpAndSettle();
}

/* ------------------------------- UTILITY METHODS ------------------------------------ */

/// Get the GlobalKeys of the form fields
/// and return them as a list
List<GlobalKey<FormBuilderFieldState>> _getFieldKeys() {
  List<FormBuilderTextField> list = find
      .bySubtype<FormBuilderTextField>()
      .evaluate()
      .map((el) => el.widget as FormBuilderTextField)
      .toList();
  List<GlobalKey<FormBuilderFieldState>> keys = list
      .map((widget) => widget.key)
      .cast<GlobalKey<FormBuilderFieldState<FormBuilderField, dynamic>>>()
      .toList();
  //FormBuilderTextField form = find.bySubtype<FormBuilderTextField>().evaluate().first.widget as FormBuilderTextField;
  //GlobalKey<FormBuilderFieldState> key = form.key as GlobalKey<FormBuilderFieldState>;
  return keys;
}
