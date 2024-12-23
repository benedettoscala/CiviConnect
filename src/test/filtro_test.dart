import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
//import 'package:form_builder_validators/form_builder_validators.dart';


/// | **Test Case ID** | **Test Frame**          | **Outcome**                       |
/// |------------------|-------------------------|------------------------------------|
/// | TC_6.0_1         | VC1                     | Error: Category is not valid      | enum is tested by the enum itself
/// | TC_6.0_2         | VC2 FD1                 | Error: Invalid date format        | enum is tested by the enum itself
/// | TC_6.0_3         | VC2 FD2 VD1             | Error: Invalid date               | enum is tested by the enum itself
/// | TC_6.0_4         | VC2 FD2 VD2 VP1         | Error: Invalid priority           | enum is tested by the enum itself
/// | TC_6.0_5         | VC2 FD2 VS2 VP2 VS1     | Error: Invalid status             | enum is tested by the enum itself
/// | TC_6.0_6         | VC2 FD2 VS2 VP2 VS2     | Correct                           |
/// | TC_6.0_7         | LR1                     | Error: Incorrect search length    |
/// | TC_6.0_8         | LR2                     | Correct                           |
/// | TC_6.0_9         | LA1                     | Error: Incorrect city length      |
/// | TC_6.0_10        | LA2                     | Correct                           |
/// | TC_6.0_11        | VC2 FD2 VS2 VP2 VS2     | Correct                           |



void main() {
  // Inizializza il binding per i test Flutter
  TestWidgetsFlutterBinding.ensureInitialized();

  _testSearch(description: 'TC_6.0_7', input: 'a'*300, expected: 'Lunghezza search deve essere inferiore a 255', reason: 'Il campo search deve rispettare la lunghezza massima di 255 caratteri');
  _testSearch(description: 'TC_6.0_8', input: 'a'*254, expected: '', reason: 'Il campo search ha lungezza minore di 255 caratteri');
 _testComune(description: 'TC_6.0_9',input: 'a'*300, expected: 'Lunghezza comune deve essere inferiore a 255',reason: 'Il campo comune deve rispettare la lunghezza massima di 255 caratteri');
 _testComune(description: 'TC_6.0_10',input: 'a',expected: null,reason: 'Il campo comune ha lungezza minore di 255 caratteri');


 /// test with enums
  /*
  _testForm(description: 'TC_6.0_1', status: StatusReport.accepted , priority:PriorityReport.medium , category: Category.values[8], data: DateTime.now(), expected: 'Errore Categoria non valida', reason: 'Categoria non valida');
 _testForm(description: 'TC_6.0_2', status: StatusReport.accepted, priority: PriorityReport.medium , category: Category.roadDamage, data: DateTime.parse("2022-10-11"), expected: 'Errore Formato data non valido', reason: '');
  _testForm(description: 'TC_6.0_3', status: StatusReport.accepted , priority:PriorityReport.medium , category: Category.roadDamage, data:DateTime.now().add(Duration(days: 1)), expected:'Errore Data non valida', reason: 'Data non valida');
  _testForm(description: 'TC_6.0_4', status: StatusReport.accepted, priority: PriorityReport.values[10], category: Category.roadDamage, data: DateTime.now(), expected: 'Errore Priorità non valida', reason: 'Priorità non valida');
  _testForm(description: 'TC_6.0_5', status:  StatusReport.values[10], priority: PriorityReport.medium, category: Category.roadDamage, data: DateTime.now(), expected: 'Errore Stato non valido', reason: 'Stato non valido');
  _testForm(description: 'TC_6.0_6', status: StatusReport.accepted, priority: PriorityReport.medium, category: Category.roadDamage, data: DateTime.now(), expected: null, reason: 'Corretto');
  _testForm(description: 'TC_6.0_11', status: StatusReport.accepted, priority: PriorityReport.medium, category: Category.roadDamage, data: DateTime.now(), expected: null, reason: 'Corretto');
_
*/

}
/// Test for city field
void _testComune({required String description,required String input,required String? expected,required String reason}) {
  testWidgets(description, (tester) async {
    final key = GlobalKey<FormBuilderFieldState>();

    // Renderizza il widget contenente il campo FormBuilderTextField
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormBuilder(
            child: FormBuilderTextField(
              name: 'comune',
              key: key,
              initialValue: input, // Valore iniziale valido
              validator: FormBuilderValidators.maxLength(
                255,
                errorText: 'Lunghezza comune deve essere inferiore a 255',
              ),
            ),
          ),
        ),
      ),
    );

    // Trova il campo "comune"
    final comuneField = find.byType(FormBuilderTextField);
    expect(comuneField, findsOneWidget,
        reason: 'Il campo comune deve essere presente nel widget tree.');
    //print(input);
    //print(comuneField.hasFound);

    // Esegui la validazione del campo
   key.currentState?.validate();
    //String errorText= 'null';
    if(expected==null){
      //print('$description:expected: $errorText reason: $reason');
    }
    else{
      //print('$description:expected:$expected reason: $reason');
    }

    // Verifica che l'errore sia quello atteso
    expect(key.currentState?.errorText, expected,
        reason: reason);


  });
}

/// Test for search field
void _testSearch({required String description,required String input,required String? expected,required String reason}) {
  testWidgets(description, (tester) async {
    // Crea il widget da testare

    String errorText = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              color: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        onSubmitted: (value) {
                          if (value.length > 255) {
                            errorText = expected!;
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'Cerca segnalazione...',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    //print("Stampa dell input" +input);

    // Trova il TextField e inserisci il testo lungo
    await tester.enterText(find.byType(TextField), input);

    // Simula l'invio del testo
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    // Verifica il risultato
    expect(errorText, expected, reason: reason);

    //print('$description:expected: $errorText reason:$reason');
  });
}


/// Test for all the field of the form
/*
void _testForm({
  required String description,
  required StatusReport status,
  required PriorityReport priority,
  required Category category,
  required DateTime data,
  required String? expected,
  required String reason,
}) {
  testWidgets('FilterModal should display correctly and handle interactions',
          (WidgetTester tester) async {
        // Mock callbacks
        bool onSubmitCalled = false;



        // Costruzione del widget con dati di esempio
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FilterModal(
                onSubmit: ({
                  required String city,
                  List<StatusReport>? status,
                  List<PriorityReport>? priority,
                  List<Category>? category,
                  DateTimeRange? dateRange,
                  bool? isCityEnabled,
                  bool? popNav,
                }) {
                  onSubmitCalled = true;
                },
                onReset: () {
                },
                startCity: 'Salerno',
                isCityEnabled: true,
                statusCriteria: const [StatusReport.inProgress],
                priorityCriteria: const [PriorityReport.high],
                categoryCriteria:  [Category.values[8]],
                defaultCity: 'Salerno',
                dateRange: DateTimeRange(
                  start: DateTime(2023, 01, 01),
                  end: DateTime(2023, 12, 31),
                ),
              ),
            ),
          ),
        );






            await tester.ensureVisible(find.byType(FormBuilderTextField));
            await tester.enterText(find.byType(FormBuilderTextField), 'BLITZ');


            await tester.ensureVisible(find.text('Filtra'));
            await tester.tap(find.text('Filtra'));
            await tester.pump();
          



            expect(onSubmitCalled, expected, reason: reason);


      

      });
}


 */




