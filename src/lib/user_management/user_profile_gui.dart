import 'package:civiconnect/model/users_model.dart';
import 'package:civiconnect/theme.dart';
import 'package:civiconnect/user_management/user_management_controller.dart';
import 'package:civiconnect/user_management/user_management_dao.dart';
import 'package:civiconnect/widgets/modal_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/snackbar_riscontro.dart';

/// Widget stateful for viewing and editing user profile data.
class UserProfile extends StatefulWidget {
  /// Widget stateful for viewing and editing user profile data.
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Variable State
  bool isEditing = false;
  Map<String, dynamic> userData = {};
  late UserManagementController userController;
  bool isLoading = true; // Indica se i dati sono in caricamento
  late ThemeData theme;
  late TextStyle textStyle;
  late GenericUser userInfo;
  User _user = UserManagementDAO().currentUser!;

  @override
  void initState() {
    super.initState();
    theme = ThemeManager().customTheme;
    textStyle = theme.textTheme.titleMedium!.copyWith(fontSize: 16);
    userController =
        UserManagementController(redirectPage: const UserProfile());
    _loadUserData();
  }

  /// Load the user data only once and save it in the state.
  void _loadUserData() async {
    late Map<String, dynamic> data;
    try {
      userInfo = (await UserManagementDAO().determineUserType())!;
      if (userInfo is Citizen) {
        data = await userController.getUserData();
      } else {
        data = await userController.getMunicipalityData();
      }
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showMessage(context,
          isError: true, message: 'Errore durante il caricamento dei dati: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: userData.isEmpty
          ? Center(
              child: Text(
                'Nessun dato utente disponibile.',
                style: theme.textTheme.titleMedium,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 0),
                    _buildProfileHeader(theme, _user, userData),
                    const SizedBox(height: 30),
                    if (userInfo is Citizen) ..._buildCitizenData(),
                    const SizedBox(height: 20),
                    Text(
                      'Dati Account',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildAccountData(_user, theme),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          UserManagementDAO().logOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FirstPage()),
                            (route) => false,
                          );
                        },
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _buildCitizenData() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Dati Personali',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () async {
              if (isEditing) {
                // Tenta di salvare i dati
                bool success = await _saveUserData();
                if (success) {
                  setState(() {
                    isEditing = false;
                  });
                }
                // If saving fails, keep isEditing = true
              } else {
                // Enter edit mode
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      const SizedBox(height: 10),
      ..._buildPersonalData(userData, theme),
      const SizedBox(height: 20),
      const Divider(
        thickness: 1,
        height: 10,
        color: Color.fromRGBO(0, 69, 118, 1),
      ),
    ];
  }

  /// Build the personal data fields.
  List<Widget> _buildPersonalData(
      Map<String, dynamic> userData, ThemeData theme) {
    // Defining the fields to display
    final Map<String, dynamic> personalFields = {
      'Nome': userData['firstName'] ?? 'N/A',
      'Cognome': userData['lastName'] ?? 'N/A',
      'Indirizzo': userData['address'],
      'Città': userData['city'] ?? 'N/A',
      'CAP': userData['cap'] ?? 'N/A',
    };

    return personalFields.keys.toList().map((field) {
      if (field == 'Indirizzo') {
        // Estrazione di street e number dall'indirizzo
        String street = personalFields['Indirizzo']['street'] ?? 'N/A';
        String number = personalFields['Indirizzo']['number'] ?? 'N/A';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Etichetta Indirizzo
              Expanded(
                flex: 2,
                child: Text(
                  '$field:',
                  style: textStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              // Via e Numero affiancati
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    // Campo Via
                    Flexible(
                      child: isEditing
                          ? _buildInputWidget(context, street, (newValue) {
                              setState(() {
                                personalFields['Indirizzo']['street'] =
                                    newValue;
                              });
                            })
                          : Text(
                              street,
                              style: textStyle,
                            ),
                    ),
                    // Width Street to number
                    const SizedBox(width: 10), // Da 10 a 5
                    // Campo Numero
                    Flexible(
                      child: isEditing
                          ? _buildInputWidget(context, number, (newValue) {
                              setState(() {
                                personalFields['Indirizzo']['number'] =
                                    newValue;
                              });
                            })
                          : Text(
                              number,
                              style: textStyle,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        // Manage all other fields
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '$field:',
                  style: textStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 5,
                child: isEditing
                    ? _buildInputWidget(context, personalFields[field],
                        (newValue) {
                        setState(() {
                          // Update the userData map with the new value
                          switch (field) {
                            case 'Nome':
                              userData['firstName'] = newValue;
                              break;
                            case 'Cognome':
                              userData['lastName'] = newValue;
                              break;
                            case 'Città':
                              userData['city'] = newValue;
                              break;
                            case 'CAP':
                              userData['cap'] = newValue;
                              break;
                          }
                        });
                      })
                    : Text(
                        personalFields[field].toString(),
                        style: textStyle,
                      ),
              ),
            ],
          ),
        );
      }
    }).toList();
  }

  Widget _buildInputWidget(BuildContext context, show, store) {
    return TextFormField(
      initialValue: show.toString(),
      style: textStyle.copyWith(fontSize: 16),
      decoration: const InputDecoration(
        border: InputBorder.none, // Rimuove il bordo
        isDense: true,
        contentPadding: EdgeInsets.zero, // Rimuove il padding
      ),
      onChanged: store,
    );
  }

  /// Save the user data to Firestore after validation checks.
  Future<bool> _saveUserData() async {
    List<String> errors = [];

    // Extracting and trimming the fields
    Map<String, dynamic>? address = userData['address'];

    // Check for empty fields
    final Map<String, String> fields = {
      'Nome': (userData['firstName'] ?? '').toString().trim(),
      'Cognome': (userData['lastName'] ?? '').toString().trim(),
      'Via': address != null ? (address['street'] ?? '').toString().trim() : '',
      'Numero Civico':
          address != null ? (address['number'] ?? '').toString().trim() : '',
      'Città': (userData['city'] ?? '').toString().trim(),
      'CAP': (userData['cap'] ?? '').toString().trim(),
    };

    final Map<String, RegExp> regexValidators = {
      'Nome': RegExp(r"^[A-Za-zÀ-ÿ\s']{1,255}$"),
      'Cognome': RegExp(r"^[A-Za-zÀ-ÿ\s']{1,255}$"),
      'Via': RegExp(r"^[A-Za-zÀ-ÿ\s']{1,255}$"),
      'Numero Civico': RegExp(r'^[A-Za-z0-9/]{1,10}$'),
      'Città': RegExp(r"^[A-Za-zÀ-ÿ\s']{1,255}$"),
      'CAP': RegExp(r'^\d{5}$'),
    };

    final Map<String, String> errorMessages = {
      'Nome':
          'Il campo "Nome" può contenere solo lettere, spazi e apostrofi (max 255 caratteri).',
      'Cognome':
          'Il campo "Cognome" può contenere solo lettere, spazi e apostrofi (max 255 caratteri).',
      'Via':
          'Il campo "Via" può contenere solo lettere, spazi, apostrofi e caratteri accentati (max 255 caratteri).',
      'Numero Civico':
          'Il campo "Numero Civico" può contenere solo lettere, numeri e "/" (max 10 caratteri).',
      'Città':
          'Il campo "Città" può contenere solo lettere, spazi e apostrofi (max 255 caratteri).',
      'CAP': 'Il campo "CAP" deve essere esattamente composto da 5 cifre.',
    };

    for (var entry in fields.entries) {
      if (entry.value.isEmpty) {
        errors.add('Il campo "${entry.key}" non può essere vuoto.');
      } else if (!regexValidators[entry.key]!.hasMatch(entry.value)) {
        errors.add(errorMessages[entry.key]!);
      }
    }

    // If there are errors, show a snackbar and return false
    if (errors.isNotEmpty) {
      String errorMessage = errors.join('\n');
      showMessage(context, isError: true, message: errorMessage);
      return false; // Save failed
    }

    // If there are no errors, save the data
    try {
      await userController.updateUserData(userData);
      showMessage(context, message: 'Dati salvati con successo');
      return true; // Save successful
    } catch (e) {
      showMessage(context,
          isError: true, message: 'Errore durante il salvataggio: $e');
      return false; // Save failed
    }
  }

  Widget _buildProfileHeader(
      ThemeData theme, User user, Map<String, dynamic> userData) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 80,
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : AssetImage(
                    'assets/images/profile/${user.uid.hashCode % 6}.jpg'),
            //child: user.photoURL == null ? Icon(Icons.person, size: 80) : null,
          ),
          const SizedBox(height: 5),
          Text(
            "Bentornato, ${userData['firstName'] ?? 'User'}!",
            style: theme.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountData(User user, ThemeData theme) {
    Widget buildRow(String label, String value) => Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            Expanded(
              flex: 3,
              child: Text(value, style: theme.textTheme.titleMedium),
            ),
          ],
        );

    Widget buildButton(IconData icon, String label, VoidCallback onPressed) =>
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(icon),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: const TextStyle(fontSize: 14)),
            ),
            onPressed: onPressed,
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRow('Email:', user.email ?? 'N/A'),
        const SizedBox(height: 10),
        if (userInfo is Citizen) ...[
          buildRow('Password:', '********'),
          const SizedBox(height: 10),
        ],
        if (userInfo is Municipality) ...[
          buildRow('Comune:', userData['municipalityName'] ?? 'N/A'),
          const SizedBox(height: 10),
          buildRow('Provincia:', userData['province'] ?? 'N/A'),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            if (userInfo is Citizen) ...[
              const SizedBox(height: 10),
              buildButton(Icons.email, 'Modifica Email',
                  () => _showChangeEmailSheet(true)),
              const SizedBox(width: 7),
              buildButton(Icons.lock, 'Modifica Password',
                  () => _showChangeEmailSheet(false)),
            ]
          ],
        ),
      ],
    );
  }

  void _showChangeEmailSheet(isEmail) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => isEmail
            ? ChangeEmailSheet(
                onSubmit: (newEmail, currentPassword) async {
                  Navigator.of(context).pop();
                  await _changeEmail(newEmail, currentPassword);
                },
              )
            : ChangePasswordSheet(
                onSubmit:
                    (currentPassword, newPassword, confirmPassword) async {
                  Navigator.of(context).pop();
                  await _changePassword(currentPassword, newPassword);
                },
              ));
  }

  Future<void> _changeEmail(String newEmail, String currentPassword) async {
    try {
      await userController.changeEmail(context,
          newEmail: newEmail, currentPassword: currentPassword);

      // Update the user data in the state
      setState(() {
        _user = FirebaseAuth.instance.currentUser!;
      });

      showMessage(context, message: 'Email aggiornata con successo');
    } catch (e) {
      _handleAuthException(e as Exception);
    }
  }

  Future<void> _changePassword(
      String currentPassword, String newPassword) async {
    try {
      await userController.changePassword(context,
          currentPassword: currentPassword, newPassword: newPassword);
      showMessage(context, message: 'Password aggiornata con successo');
    } catch (e) {
      _handleAuthException(e as Exception);
    }
  }

  void _handleAuthException(Exception e) {
    String errorMessage;
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'L\'email inserita non è valida.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Questa email è già in uso da un altro account.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'La password corrente non è corretta.';
          break;
        case 'weak-password':
          errorMessage = 'La nuova password è troppo debole.';
          break;
        default:
          errorMessage = 'Errore: ${e.message}';
      }
    } else {
      errorMessage = 'Si è verificato un errore: $e';
    }
    showMessage(context, isError: true, message: errorMessage);
  }
}
