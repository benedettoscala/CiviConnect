import 'package:civiconnect/model/report_model.dart';
import 'package:civiconnect/utils/report_status_priority.dart';
import 'package:civiconnect/widgets/filter_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:form_builder_validators/form_builder_validators.dart';

/// TC_6.0_1
/// VC1
/// Errore: Categoria non valida
/// TC_6.0_2
/// VC2 FD1
/// Errore: Formato data non valido
/// TC_6.0_3
/// VC2 FD2 VD1
/// Errore: Data non valida
/// TC_6.0_4
/// VC2 FD2 VD2 VP1
/// Errore: Priorità non valida
/// TC_6.0_5
/// VC2 FD2 VS2 VP2 VS1
/// Errore: Stato non valido
/// TC_6.0_6
/// VC2 FD2 VS2 VP2 VS2 L1
/// Errore: Lunghezza non corretta
/// TC_6.0_7
/// VC2 FD2 VS2 VP2 VS2 L2
/// Corretto







void main() {
  // Inizializza il binding per i test Flutter
  TestWidgetsFlutterBinding.ensureInitialized();

  // Esegui i test
  //_testComune(description: "TC_6.0_1",input: "a"*300, expected: "Lunghezza comune inferiore a 255",reason: "Il campo comune deve rispettare la lunghezza massima di 255 caratteri");
 // _testComune(description: "TC_6.0_2",input: "a",expected: null,reason: "Il campo comune ha lungezza minore di 255 caratteri");

  _testForm(description: 'TC_6.0_1', status: StatusReport.accepted , priority:PriorityReport.medium , category: Category.values[8], data: DateTime.now(), expected: 'Errore Categoria non valida', reason: 'Categoria non valida');
  /*_testForm(description: 'TC_6.0_2', status: status, priority: priority, category: category, data: data, expected: expected, reason: reason);
  _testForm(description: 'TC_6.0_3', status: status, priority: priority, category: category, data: data, expected: expected, reason: reason);
  _testForm(description: 'TC_6.0_4', status: status, priority: priority, category: category, data: data, expected: expected, reason: reason);
  _testForm(description: 'TC_6.0_5', status: status, priority: priority, category: category, data: data, expected: expected, reason: reason);
  _testForm(description: 'TC_6.0_6', status: status, priority: priority, category: category, data: data, expected: expected, reason: reason);
  _testForm(description: 'TC_6.0_7', status: status, priority: priority, category: category, data: data, expected: expected, reason: reason);*/
}
/*
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
}*/


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



            expect(onSubmitCalled, false);


      

      });
}




