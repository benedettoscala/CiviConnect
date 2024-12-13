import 'package:civiconnect/model/users_model.dart';
import 'package:civiconnect/user_management/user_management_controller.dart';
import 'package:civiconnect/user_management/user_profile_gui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Implementazione fake del controller UserManagement per i test.
class FakeUserManagementController extends Fake implements UserManagementController {
  final bool _isLoggedIn;

  FakeUserManagementController({required bool isLoggedIn}) : _isLoggedIn = isLoggedIn;

  @override
  Future<void> logOut() async {
    if (!_isLoggedIn) {
      throw Exception('Errore durante il logout');
    }
  }

  @override
  User? getcurrentUser() => FakeUser();

  @override
  Future<Map<String, dynamic>> getUserData() async => {
    'firstName': FakeUser().displayName,
    'lastName': FakeUser().displayName,
    'address': {
      'via': FakeUser().via,
      'civ': FakeUser().civ,
    },
    'city': FakeUser().city,
    'cap': FakeUser().cap,
  };

  @override
  Future<GenericUser?> determineUserType() async => Citizen(user: FakeUser());

  @override
  Future<Map<String, String>> getMunicipalityData() async => {
    'municipalityName': 'Roma',
    'province': 'RM',
  };

  @override
  Future<void> updateUserData(Map<String, dynamic> data) async {}

  @override
  Future<void> changeEmail(BuildContext context,
      {required String newEmail, required String currentPassword}) async {}

  @override
  Future<void> changePassword(BuildContext context,
      {required String newPassword, required String currentPassword}) async {}
}

/// Implementazione fake della classe User per i test.
class FakeUser extends Fake implements User {
  @override
  String get email => 'Testing@gmail.com';

  @override
  String get displayName => 'Test User';

  @override
  String get uid => '2';

  String get via => 'Via Roma';
  String get civ => '12';
  String get city => 'Roma';
  String get cap => '00100';
  @override
  String? get photoURL => null;

  @override
  Future<void> reload() async {}

  @override
  Future<void> delete() async {}
}

void main() {
    testWidgets('Logout TC_2.0.1', (tester) async {
      final controller = FakeUserManagementController(isLoggedIn: false);

      await _setUpTestEnv(tester: tester, controller: controller);

      await _performLogout(tester);

      // Verifica che venga mostrato un messaggio di errore
      expect(find.text('Errore durante il logout'), findsOneWidget,
          reason: 'Expected an error message when logout fails');
    });

    /*testWidgets('TC_2.0.2: Logout succeeds when user is logged in', (tester) async {
      final controller = FakeUserManagementController(isLoggedIn: true);

      await _setUpTestEnv(tester: tester, controller: controller);

      await _performLogout(tester);

      // Verifica che l'utente venga reindirizzato alla pagina di login
      expect(find.text('Logout'), findsOneWidget,
          reason: 'Expected user to be redirected to the login page after logout');
    });*/
}

/// Configura l'ambiente di test e inietta il controller fake.
Future<void> _setUpTestEnv({
  required WidgetTester tester,
  required FakeUserManagementController controller,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: UserProfile(controller: controller),
    ),
  );
  await tester.pumpAndSettle();

  // Verifica che la pagina del profilo utente sia visualizzata correttamente
  expect(find.text('Logout'), findsOneWidget,
      reason: 'Logout button should be present on the UserProfile page');
}

/// Simula il processo di logout.
Future<void> _performLogout(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Logout'));
  await tester.tap(find.text('Logout'));
  await tester.pumpAndSettle();
}