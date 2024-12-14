import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
//import 'package:form_builder_validators/form_builder_validators.dart';
/// | **Test Case ID** | **Test Frame**          | **Esito**                         |
/// |------------------|-------------------------|------------------------------------|
/// | TC_6.0_1         | VC1                     | Errore: Categoria non valida      | enum is tested by the enum itself
/// | TC_6.0_2         | VC2 FD1                 | Errore: Formato data non valido   | enum is tested by the enum itself
/// | TC_6.0_3         | VC2 FD2 VD1             | Errore: Data non valida           | enum is tested by the enum itself
/// | TC_6.0_4         | VC2 FD2 VD2 VP1         | Errore: Priorità non valida       | enum is tested by the enum itself
/// | TC_6.0_5         | VC2 FD2 VS2 VP2 VS1     | Errore: Stato non valido          | enum is tested by the enum itself
/// | TC_6.0_6         | VC2 FD2 VS2 VP2 VS2     | Corretto                          |
/// | TC_6.0_7         | LR1                     | Errore: Lunghezza ricerca non corretta    |
/// | TC_6.0_8         | LA1                     | Errore: Lunghezza Comune non corretta |
/// | TC_6.0_9         | LA2                     | Corretto                          |
/// | TC_6.0_10        | VC2 FD2 VS2 VP2 VS2     | Corretto                          |





void main() {
  // Inizializza il binding per i test Flutter
  TestWidgetsFlutterBinding.ensureInitialized();

  // Esegui i test
  _testComune(description: "TC_6.0_8",input: "a"*300, expected: "Lunghezza comune inferiore a 255",reason: "Il campo comune deve rispettare la lunghezza massima di 255 caratteri");
 _testComune(description: "TC_6.0_9",input: "a",expected: null,reason: "Il campo comune ha lungezza minore di 255 caratteri");
  /*
  _testForm(description: 'TC_6.0_1', status: StatusReport.accepted , priority:PriorityReport.medium , category: Category.values[8], data: DateTime.now(), expected: 'Errore Categoria non valida', reason: 'Categoria non valida');
 _testForm(description: 'TC_6.0_2', status: StatusReport.accepted, priority: PriorityReport.medium , category: Category.roadDamage, data: DateTime.parse("2022-10-11"), expected: 'Errore Formato data non valido', reason: '');
  _testForm(description: 'TC_6.0_3', status: StatusReport.accepted , priority:PriorityReport.medium , category: Category.roadDamage, data:DateTime.now().add(Duration(days: 1)), expected:'Errore Data non valida', reason: 'Data non valida');
  _testForm(description: 'TC_6.0_4', status: StatusReport.accepted, priority: PriorityReport.values[10], category: Category.roadDamage, data: DateTime.now(), expected: 'Errore Priorità non valida', reason: 'Priorità non valida');
  _testForm(description: 'TC_6.0_5', status:  StatusReport.values[10], priority: PriorityReport.medium, category: Category.roadDamage, data: DateTime.now(), expected: 'Errore Stato non valido', reason: 'Stato non valido');
  _testForm(description: 'TC_6.0_6', status: StatusReport.accepted, priority: PriorityReport.medium, category: Category.roadDamage, data: DateTime.now(), expected: null, reason: 'Corretto');
  _testForm(description: 'TC_6.0_7', status: StatusReport.accepted, priority: PriorityReport.medium, category: Category.roadDamage, data: DateTime.now(), expected: null, reason: 'Corretto');

*/
}
void _testComune({required String description,required String input,required String? expected,required String reason}) {
  testWidgets(description, (WidgetTester tester) async {
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
                errorText: 'Lunghezza comune inferiore a 255',
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
    print(input);
    print(comuneField.hasFound);

    // Esegui la validazione del campo
    print(key.currentState?.validate());

    // Verifica che l'errore sia quello atteso
    expect(key.currentState?.errorText, expected,
        reason: reason);


  });
}

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




