import 'package:civiconnect/model/users_model.dart';
import 'package:civiconnect/user_management/user_management_controller.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:civiconnect/user_management/user_profile_gui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockUser extends Mock implements User {}
class MockMunicipality extends Mock implements Municipality {}
class FakeUser extends Fake implements User {
  String? get photoURL => null;

  String email = 'email';

  @override
  String get uid => '123';
}
///MockUser us = MockUser();
FakeUser us = FakeUser();
MockMunicipality mun = MockMunicipality();

/// Implementazione fake del controller UserManagement per i test.
class FakeUserManagementDAO extends Fake implements UserManagementDAO {
  final bool isLoggedIn;

  FakeUserManagementDAO({required this.isLoggedIn});

  @override
  Future<GenericUser?> determineUserType() {
    // TODO: implement determineUserType
    return Future.value(mun);
  }

  @override
  Future<Map<String, String>> getMunicipalityData() {
    return Future(() => {'municipalityName': 'Arezzo', 'email': 'email',
      'province': 'PR',});
  }

  @override
  Future<Map<String, dynamic>> getUserData() {
    throw UnimplementedError();
  }

  @override
  User? get currentUser => us;

  @override
  Future<void> logOut() async {
    if(isLoggedIn) {
      return;
    } else {
      throw Exception('Errore durante il logout');
    }
  }
}


bool isLoggedIn = false;
void main() {


    testWidgets('Logout TC_2.0.1', (tester) async {
      isLoggedIn = false;
      final controller = UserManagementController(userManagementDAO: FakeUserManagementDAO(isLoggedIn: isLoggedIn));

      await _setUpTestEnv(tester: tester, controller: controller);

      await _performLogout(tester);

      // Verifica che venga mostrato un messaggio di errore
      expect(find.text('Errore durante il logout'), findsOneWidget,
          reason: 'Expected an error message when logout fails');
    });



    testWidgets('TC_2.0.2: Logout succeeds when user is logged in', (tester) async {
      isLoggedIn = true;
      final controller = UserManagementController(userManagementDAO: FakeUserManagementDAO(isLoggedIn: isLoggedIn));

      await _setUpTestEnv(tester: tester, controller: controller);

      await _performLogout(tester);

      // Verifica che l'utente venga reindirizzato alla pagina di login
      expect(find.text('Logout'), findsNothing,
          reason: 'Expected user to be redirected to the login page after logout');
    });
}

/// Configura l'ambiente di test e inietta il controller fake.
Future<void> _setUpTestEnv({
  required WidgetTester tester,
  required UserManagementController controller,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: UserProfile(controller: controller, redirectLogOutPage: const Placeholder(),),
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
