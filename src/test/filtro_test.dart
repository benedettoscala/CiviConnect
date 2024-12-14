import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

void main() {
  // Inizializza il binding per i test Flutter
  TestWidgetsFlutterBinding.ensureInitialized();

  // Esegui i test
  _testComune(description: "TC_6.0_1",input: "a"*300, expected: "Lunghezza comune inferiore a 255",reason: "Il campo comune deve rispettare la lunghezza massima di 255 caratteri");
  _testComune(description: "TC_6.0_1",input: "a",expected: null,reason: "Il campo comune ha lungezza minore di 255 caratteri");

  _testData(
      description: 'Test Date Range Picker with valid dates',
      input1: '2024-12-10T12:30:00.000Z',
      input2: '2024-12-11T12:30:00.000Z',
      expected: 'Intervallo non valido',
      reason: 'Intervallo non esistente',
  );
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
void _testDatePicker({required String description, required String input1 , required String input2, required String? expected, required String reason}) {
  testWidgets(description, (WidgetTester tester) async {
    // Definizione dell'intervallo iniziale selezionato
    DateTimeRange? selectedDate;
      DateTime? a = DateTime.tryParse(input1);
      DateTime? b = DateTime.tryParse(input2);
      print(a);
      print(b);
      if(a==null || b==null){
        print("Data non valida");
        expect(a, isNull, reason: 'La data deve essere in un formato valido.');
        expect(b, isNull, reason: 'La data deve essere in un formato valido.');
        return;
      }

    // Metodo che simula il DatePickerDialog
    Future<DateTimeRange?> _datePickerDialog(BuildContext context) {
      return showDateRangePicker(
        context: context,
        firstDate: DateTime(2023),
        lastDate: DateTime.now(),
        confirmText: 'Conferma',
        errorInvalidRangeText: 'Intervallo non valido',
        errorFormatText: 'Formato non valido',
        fieldStartHintText: 'Inizio',
        fieldEndHintText: 'Fine',
        currentDate: DateTime.now(),
        initialDateRange: DateTimeRange(start: a, end: b),
        locale: const Locale('it', 'IT'),
        helpText: 'Seleziona un intervallo di date',
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 300, // Imposta un limite alla larghezza
                      maxHeight: 400, // Imposta un limite all'altezza
                    ),
                    child: child,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    // Widget con il pulsante che apre il DatePickerDialog
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  selectedDate = await _datePickerDialog(context);
                },
                child: const Text('Apri Date Picker'),
              );
            },
          ),
        ),
      ),
    );
      
      print("selectedDate"+ selectedDate.toString());
    print("to local");
    print(a.toLocal());
    print(b.toLocal());


    // Trova il pulsante e simula un tap per aprire il DatePickerDialog
    final button = find.byType(ElevatedButton);
    expect(button, findsOneWidget, reason: 'Il pulsante deve essere presente nel widget tree.');
    await tester.tap(button);

    // Ricostruisci il widget tree per mostrare il dialog
    await tester.pumpAndSettle();

    // Trova i campi del DatePicker
    final startHint = find.text('Inizio');
    final endHint = find.text('Fine');
    final confirmButton = find.text('Conferma');

    expect(startHint, findsOneWidget, reason: 'Il campo di inizio deve essere visibile.');
    expect(endHint, findsOneWidget, reason: 'Il campo di fine deve essere visibile.');
    expect(confirmButton, findsOneWidget, reason: 'Il pulsante di conferma deve essere visibile.');

    // Simula un tap su "Conferma" senza selezionare un range valido
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    if (a.isAfter(b)) {
      final errorMessage = find.text('Intervallo non valido');
      expect(errorMessage, findsOneWidget, reason: reason);
    }

    // Trova il messaggio di errore
    final errorMessage = find.text('Intervallo non valido');
    expect(expected, findsOneWidget, reason: reason);
  });
}


 */

void _testData({
  required String description,
  required String input1,
  required String input2,
  required String? expected,
  required String reason,
}) {
  testWidgets(description, (WidgetTester tester) async {

    // Impostazione delle date
    DateTime firstDate = DateTime(2020);
    DateTime lastDate = DateTime(2100);

    // Stampa dei valori di firstDate e lastDate
    print('First Date: $firstDate');
    print('Last Date: $lastDate');

    // Creazione del widget con DateRangePickerDialog
    Widget createDateRangePickerDialogWidget() {
      return MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', 'US')],
        home: Scaffold(
          body: Center(
            child: DateRangePickerDialog(
              initialDateRange: DateTimeRange(
                start: DateTime.parse(input1),
                end: DateTime.parse(input2),
              ),
              firstDate: firstDate,
              lastDate: lastDate,
            ),
          ),
        ),
      );
    }

    // Eseguiamo il widget di test
    await tester.pumpWidget(createDateRangePickerDialogWidget());
    await tester.pumpAndSettle(); // Assicura che il widget si sia caricato completamente

    // Verifica che il DateRangePickerDialog sia presente
    expect(find.byType(DateRangePickerDialog), findsOneWidget);

    // Verifica il testo che ti aspetti come "expected"
    if (expected != null) {
      expect(find.text(expected), findsOneWidget);
    }

    // Puoi anche aggiungere altre asserzioni, come la verifica dei valori di data
    print('Inizio: $input1, Fine: $input2');
  });
}



