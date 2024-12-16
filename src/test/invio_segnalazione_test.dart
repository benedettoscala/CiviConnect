import 'dart:io';
import 'package:civiconnect/gestione_segnalazione_cittadino/gestione_segnalazione_cittadino_controller.dart';
import 'package:civiconnect/gestione_segnalazione_cittadino/inserimento_segnalazione_gui.dart';
import 'package:civiconnect/model/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'invio_segnalazione_test.mocks.dart';

/// A fake controller for the Insert Report Widget
class FakeInserimentoSegnalazioneController extends Fake
    implements CitizenReportManagementController {
  final bool validCoordinates;

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
        255 && descrizione.length <= 1023
        && (categoria == Category.getCategory('Rifiuti')
        && location.latitude != 0 && location.longitude != 0 &&
        indirizzo!['address'] != ''
        && indirizzo['city'] != '' && photo!.path.endsWith('.jpg'))
    ) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  FakeInserimentoSegnalazioneController({this.validCoordinates = true});

  @override
  bool containsBadWords(String text, List<String> badWords) {
    return text.contains('badWord');
  }

  @override
  Future<List<String>> getBadWords() {
    return Future.value(
        ['badword1', 'badword2']); // Replace with your bad words list
  }

  @override
  Future<GeoPoint?> getCoordinates(BuildContext context) {
    return Future.value(const GeoPoint(-2.74751008128278, -0.3396995377597016));
  }

  @override
  Future<List<String>> getLocation(GeoPoint? location) {
    if (validCoordinates) {
      return Future.value(['Località', 'Via Italiana', 'Roma', 'Italy']);
    } else {
      return Future.value(['Locality', 'Via Straniera', 'Timbuktu', 'Mali']);
    }
  }
}


@GenerateMocks([CitizenReportManagementController, ImagePicker])
MockImagePicker mockedImagePicker = MockImagePicker();
void main() {
  ///Test Case TC_1.0_1
  _testDescription(
      description: 'TC_1.0_1',
      input: 'a' * 1024,
      expected: 'Massimo 1023 caratteri',
      reason: 'Description field must respect length constraints');

  ///Test Case TC_1.0_2 BadWord Descriptions
  _testDescription(
      description: 'TC_1.0_2',
      input: 'badWord',
      expected: 'Il campo contiene parole non consentite',
      reason: 'Title field must respect length constraints');

  ///Test Case TC_1.0_3
  _testTitle(
      description: 'TC_1.0_3',
      input: 'a' * 256,
      expected: 'Massimo 255 caratteri',
      reason: 'Title field must respect length constraints');

  /// Test Case TC_1.0_4 BadWords in Title
  _testTitle(
      description: 'TC_1.0_4',
      input: 'badWord',
      expected: 'Il campo contiene parole non consentite',
      reason: 'Title field must respect length constraints');


  ///Test Case TC_1.0_5
  //enum non valido è testato dall'enum stesso


  /// Test Case TC_1.0_6
  _testIndirizzo(
      description: 'TC_1.0_6',
      input: '',
      //GeoPoint(0, 0),
      expected: 'Non sei in Italia',
      reason: 'Location field must have valid coordinates');

  /*  /// Test Case TC_1.0_7 -- API dependent NON Testable (off-the-shelf)
    _testValidation(
        description: 'TC_1.0_7',
        input: '',
        //{'address': '', 'city': ''},
        expected: 'Coordinates value must be setted',
        isValid: false,
        reason: 'Address field must have valid address');*/

  /// Test Case TC_1.0_8
  _testPhoto(
      description: 'TC_1.0_8',
      input: 'image.png',
      expected: 'Invalid file extension',
      reason: 'Photo field must have valid file extension');


   /// Test Case TC_1.0_9 OK
  _testValidation(
      description: 'TC_1.0_9',
      input: 'OK',
      expected: 'Invio effettuato con successo!',
      reason: 'Report is valid and should be sent',
      isValid: true);
}

/// Test the description field
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

/// Test the title field
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

/// Test the validation of the report Address (Country)
void _testIndirizzo({required String description,
  required String input,
  required String expected,
  String? reason}) {
  testWidgets('Report Title: $description', (tester) async {
    // Load Insert Report Widget and Test Environment
    await _pumpWidgetAndTestEnv(
        tester: tester, controller: FakeInserimentoSegnalazioneController(validCoordinates: false));

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

    // Scroll to the send button
    await tester.dragUntilVisible(
      find.byKey(const Key('Invia')), // what you want to find
      find.byType(SingleChildScrollView), // widget you want to scroll
      const Offset(0, 500), // delta to move
    );

    // Tap the send button and trigger a frame.
    await tester.tap(find.text('Invia Segnalazione'));
    await tester.pumpAndSettle();

    // Get the state of the description field
    
    // Check if the error message is what we
    expect(find.text(expected), findsOneWidget, reason: reason);
  });
}

/// Test the Photo Extension of the report
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
      find.byKey(const Key('FotoSubmit')), // what you want to find - Scroll till image picker
      find.byKey(const Key('InserimentoSegnalazione')), // widget you want to scroll
      const Offset(0, 500), // delta to move
    );

    // Await for the scroll to finish
    await tester.pumpAndSettle();

    // Check if the description field is present
    expect(find.byKey(const Key('FotoSubmit')), findsOneWidget,
        reason: 'The description is (still) present');


    when(mockedImagePicker.pickImage(source: ImageSource.camera)).thenAnswer((_) async => XFile(input));

    // Insert text in the description field
    //
    // await tester.enterText(find.byKey(const Key('FotoSubmit')), input);
    await tester.tap(find.byKey(const Key('FotoSubmit')));
    await tester.pumpAndSettle();



    // Scroll to the send button
    await tester.dragUntilVisible(
      find.byKey(const Key('Invia')), // what you want to find
      find.byType(SingleChildScrollView), // widget you want to scroll
      const Offset(0, 500), // delta to move
    );

    // Await for the scroll to finish
    await tester.pumpAndSettle();

    // Tap the send button and trigger a frame.
    await tester.tap(find.text('Invia Segnalazione'));
    await tester.pump();

    // Get the state of the description field
    expect(find.text('Estensione immagine non valida'), findsOneWidget, reason: reason);
  });
}

/// Test the validation of the report
void _testValidation({required String description,
  required String input,
  required String expected,
  required bool isValid,
  String? reason}) {
  testWidgets('Report Validation: $description', (tester) async {
    // Load Insert Report Widget and Test Environment
    await _pumpWidgetAndTestEnv(tester: tester, controller: FakeInserimentoSegnalazioneController(validCoordinates: isValid));

    if(isValid){
      // Scroll to the description field
      await tester.dragUntilVisible(
        find.byKey(const Key('Descrizione')), // what you want to find
        find.byType(SingleChildScrollView), // widget you want to scroll
        const Offset(0, 500), // delta to move
      );

      // Insert text in the title field
      await tester.enterText(find.byKey(const Key('Titolo')), input);

      // Insert text in the description field
      await tester.enterText(find.byKey(const Key('Descrizione')), input);

      when(mockedImagePicker.pickImage(source: ImageSource.camera)).thenAnswer((_) async => XFile('image.jpg'));

      // Scroll to the send button
      await tester.dragUntilVisible(
        find.byKey(const Key('Invia')), // what you want to find
        find.byType(SingleChildScrollView), // widget you want to scroll
        const Offset(0, 500), // delta to move
      );

      await tester.pumpAndSettle();

      // Tap the send button and trigger a frame.
      await tester.tap(find.text('Invia Segnalazione'), warnIfMissed: false);
      await tester.pump();

      // Get the state of the description field
      final fieldState =
      tester.state<FormFieldState>(find.byKey(const Key('Descrizione')));
      // Check if the error message is what we
      expect(fieldState.errorText, null, reason: reason);
    }


    // Insert text in the photo field
    //await tester.enterText(find.byKey(const Key('Foto')), input);
    // Tap the send button and trigger a frame.
    await tester.tap(find.text('Invia Segnalazione'), warnIfMissed: false);
    await tester.pump();
  });
}



/* -------------------------------- GENERIC TESTING AND WIDGET PUMPS ----------------------- */

/// Load the Insert Report Widget and the Test Environment
Future<void> _pumpWidgetAndTestEnv({required WidgetTester tester,
  CitizenReportManagementController? controller}) async {
  // Load Insert Report Widget
  await tester.pumpWidget(MaterialApp(
      home: InserimentoSegnalazioneGUI(
        controller: controller,
        imagePicker: mockedImagePicker,
      )));
  await tester.pumpAndSettle();
}
