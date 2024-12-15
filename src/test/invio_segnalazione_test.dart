import 'dart:io';
import 'package:civiconnect/gestione_segnalazione_cittadino/gestione_segnalazione_cittadino_controller.dart';
import 'package:civiconnect/gestione_segnalazione_cittadino/inserimento_segnalazione_gui.dart';
import 'package:civiconnect/model/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  Future<List<String>> getBadWords() {
    return Future.value(
        ['badword1', 'badword2']); // Replace with your bad words list
  }
}

@GenerateMocks([CitizenReportManagementController])
void main() {
  ///Test Case TC_1.0_1
  _testDescription(
      description: 'TC_1.0_1',
      input: 'a' * 1024,
      expected: 'Massimo 1023 caratteri',
      reason: 'Description field must respect length constraints');

  ///Test Case TC_1.0_2
  _testTitle(
      description: 'TC_1.0_2',
      input: 'a' * 256,
      expected: 'Massimo 255 caratteri',
      reason: 'Title field must respect length constraints');

  ///Test Case TC_1.0_3
  //enum non valido è testato dall'enum stesso

  /// Test Case TC_1.0_6
  _testPhoto(
      description: 'TC_1.0_6',
      input: 'image.png',
      expected: 'Invalid file extension',
      reason: 'Photo field must have valid file extension');

  /// Test Case TC_1.0_4
 /* _testIndirizzo(
      description: 'TC_1.0_4',
      input: '',
      //GeoPoint(0, 0),
      expected: 'Indirizzo non valido',
      reason: 'Location field must have valid coordinates');*/
/*
    /// Test Case TC_1.0_5
    _testValidation(
        description: 'TC_1.0_5',
        input: '',
        //{'address': '', 'city': ''},
        expected: 'Coordinates value must be setted',
        isValid: false,
        reason: 'Address field must have valid address');


    /// Test Case TC_1.0_7
    _testValidation(
      description: 'TC_1.0_7',
      input: 'image.jpg',
      expected: 'Valid photo',
      isValid: true,
      reason: 'Photo field must have valid file extension',
    );*/
}

void _testDescription({required String description,
  required String input,
  required String expected,
  String? reason}) {
  testWidgets('Report Description: $description', (tester) async {
    // Load Insert Report Widget and Test Environment
    await _pumpWidgetAndTestEnv(
        tester: tester, controller: FakeInserimentoSegnalazioneController());

    // Scroll to the description field
    await tester.dragUntilVisible(
      find.byKey(const Key('Descrizione')), // what you want to find
      find.byType(SingleChildScrollView), // widget you want to scroll
      const Offset(0, 500), // delta to move
    );

    // Check if the description field is present
    expect(find.byKey(const Key('Descrizione')), findsOneWidget,
        reason: 'The description is (still) present');

    // Insert text in the description field
    await tester.enterText(find.byKey(const Key('Descrizione')), input);

    // Scroll to the send button
    await tester.dragUntilVisible(
      find.byKey(const Key('Invia')), // what you want to find
      find.byType(SingleChildScrollView), // widget you want to scroll
      const Offset(0, 500), // delta to move
    );

    // Tap the send button and trigger a frame.
    await tester.tap(find.text('Invia Segnalazione'));
    await tester.pump();

    // Get the state of the description field
    final fieldState =
    tester.state<FormFieldState>(find.byKey(const Key('Descrizione')));
    // Check if the error message is what we
    expect(fieldState.errorText, expected, reason: reason);
  });
}

void _testTitle({required String description,
  required String input,
  required String expected,
  String? reason}) {
  testWidgets('Report Title: $description', (tester) async {
    // Load Insert Report Widget and Test Environment
    await _pumpWidgetAndTestEnv(
        tester: tester, controller: FakeInserimentoSegnalazioneController());

    // Check if the description field is present
    expect(find.byKey(const Key('Titolo')), findsOneWidget,
        reason: 'The description is (still) present');

    // Insert text in the description field
    await tester.enterText(find.byKey(const Key('Titolo')), input);

    // Scroll to the send button
    await tester.dragUntilVisible(
      find.byKey(const Key('Invia')), // what you want to find
      find.byType(SingleChildScrollView), // widget you want to scroll
      const Offset(0, 500), // delta to move
    );

    // Tap the send button and trigger a frame.
    await tester.tap(find.text('Invia Segnalazione'));
    await tester.pump();

    // Get the state of the description field
    final fieldState =
    tester.state<FormFieldState>(find.byKey(const Key('Titolo')));
    // Check if the error message is what we
    expect(fieldState.errorText, expected, reason: reason);
  });
}

void _testIndirizzo({required String description,
  required String input,
  required String expected,
  String? reason}) {
  testWidgets('Report Title: $description', (tester) async {
    // Load Insert Report Widget and Test Environment
    await _pumpWidgetAndTestEnv(
        tester: tester, controller: FakeInserimentoSegnalazioneController());

    // Check if the description field is present
    expect(find.byKey(const Key('Indirizzo')), findsOneWidget,
        reason: 'The address is (still) present');

    // Insert text in the description field
    await tester.enterText(find.byKey(const Key('Indirizzo')), input);

    // Scroll to the send button
    await tester.dragUntilVisible(
      find.byKey(const Key('Indirizzo')), // what you want to find
      find.byType(SingleChildScrollView), // widget you want to scroll
      const Offset(0, 500), // delta to move
    );

    @override
    GeoPoint? getCoordinates() {
      return const GeoPoint(51.74751008128278, -0.3396995377597016);
    }

    Future<List<String>> list = getLocation(getCoordinates());


    // Scroll to the send button
    await tester.dragUntilVisible(
      find.byKey(const Key('Invia')), // what you want to find
      find.byType(SingleChildScrollView), // widget you want to scroll
      const Offset(0, 500), // delta to move
    );

    // Tap the send button and trigger a frame.
    await tester.tap(find.text('Invia Segnalazione'));
    await tester.pump();

    // Get the state of the description field
    final fieldState =
    tester.state<FormFieldState>(find.byKey(const Key('Indirizzo')));
    // Check if the error message is what we
    expect(fieldState.errorText, expected, reason: reason);
  });
}

void _testPhoto({required String description,
  required String input,
  required String expected,
  String? reason}) {
  testWidgets('Report Description: $description', (tester) async {
    // Load Insert Report Widget and Test Environment
    await _pumpWidgetAndTestEnv(
        tester: tester, controller: FakeInserimentoSegnalazioneController());

    // Scroll to the description field
    await tester.dragUntilVisible(
      find.byKey(const Key('Foto')), // what you want to find
      find.byType(SingleChildScrollView), // widget you want to scroll
      const Offset(0, 500), // delta to move
    );

    // Check if the description field is present
    expect(find.byKey(const Key('Foto')), findsOneWidget,
        reason: 'The description is (still) present');

    // Insert text in the description field
    await tester.enterText(find.byKey(const Key('Foto')), input);

    // Scroll to the send button
    await tester.dragUntilVisible(
      find.byKey(const Key('Invia')), // what you want to find
      find.byType(SingleChildScrollView), // widget you want to scroll
      const Offset(0, 500), // delta to move
    );

    // Tap the send button and trigger a frame.
    await tester.tap(find.text('Invia Segnalazione'));
    await tester.pump();

    // Get the state of the description field
    final fieldState =
    tester.state<FormFieldState>(find.byKey(const Key('Foto')));
    // Check if the error message is what we
    expect(fieldState.errorText, expected, reason: reason);
  });
}


void _testValidation({required String description,
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


/* -------------------------------- GENERIC TESTING AND WIDGET PUMPS ----------------------- */

Future<void> _pumpWidgetAndTestEnv({required WidgetTester tester,
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

  return keys;
}
