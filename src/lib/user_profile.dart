import 'package:civiconnect/theme.dart';
import 'package:civiconnect/user_management/user_management_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Widget stateful for viewing and editing user profile data.
class UserProfile extends StatefulWidget {
  UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Variable State
  bool isEditing = false;
  Map<String, dynamic> userData = {};
  Map<String, dynamic> originalUserData = {}; // Original user data
  late UserManagementController userController;
  bool isLoading = true; // Indica se i dati sono in caricamento

  @override
  void initState() {
    super.initState();
    userController = UserManagementController(redirectPage: UserProfile());
    _loadUserData();
  }

  /// Load the user data only once and save it in the state.
  void _loadUserData() async {
    try {
      Map<String, dynamic> data = await userController.getUserData();
      setState(() {
        userData = data;
        //originalUserData = Map<String, dynamic>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il caricamento dei dati: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeManager().customTheme;
    final user = FirebaseAuth.instance.currentUser;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Area Utente',
            style: theme.textTheme.titleLarge,
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Area Utente',
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
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
              _buildProfileHeader(theme, user!, userData),
              const SizedBox(height: 30),
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
                        // Se il salvataggio fallisce, mantieni isEditing = true
                      } else {
                        // Entra in modalità modifica
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
              const SizedBox(height: 20),
              Text(
                'Dati Account',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildAccountData(user, theme),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Segnalazioni',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPersonalData(
      Map<String, dynamic> userData, ThemeData theme) {
    // Definizione dei campi personali
    final List<Map<String, dynamic>> personalFields = [
      {'label': 'Nome', 'value': userData['firstName'] ?? 'N/A'},
      {'label': 'Cognome', 'value': userData['lastName'] ?? 'N/A'},
      {'label': 'Indirizzo', 'value': userData['address']},
      {'label': 'Città', 'value': userData['city'] ?? 'N/A'},
      {'label': 'CAP', 'value': userData['cap'] ?? 'N/A'},
    ];

    TextStyle textStyle = theme.textTheme.titleMedium!.copyWith(fontSize: 16);

    return personalFields.map((field) {
      if (field['label'] == 'Indirizzo' && field['value'] != null) {
        // Estrazione di street e number dall'indirizzo
        String street = field['value']['street'] ?? 'N/A';
        String number = field['value']['number'] ?? 'N/A';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Etichetta Indirizzo
              Expanded(
                flex: 2,
                child: Text(
                  '${field['label']}:',
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
                          ? TextFormField(
                        initialValue: street,
                        style: textStyle.copyWith(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Via',
                          border: InputBorder.none, // Rimuove il bordo
                          isDense: true,
                          contentPadding: EdgeInsets.zero, // Rimuove il padding
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            userData['address']['street'] = newValue;
                          });
                        },
                      )
                          : Text(
                        street,
                        style: textStyle,
                      ),
                    ),
                    // Riduci la larghezza dello spazio tra Via e Numero
                    const SizedBox(width: 10), // Da 10 a 5
                    // Campo Numero
                    Flexible(
                      child: isEditing
                          ? TextFormField(
                        initialValue: number,
                        style: textStyle.copyWith(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Numero',
                          border: InputBorder.none, // Rimuove il bordo
                          isDense: true,
                          contentPadding: EdgeInsets.zero, // Rimuove il padding
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (newValue) {
                          setState(() {
                            userData['address']['number'] = newValue;
                          });
                        },
                      )
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
        // Gestione degli altri campi
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '${field['label']}:',
                  style: textStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 5,
                child: isEditing
                    ? TextFormField(
                  initialValue: field['value'].toString(),
                  style: textStyle.copyWith(fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none, // Rimuove il bordo
                    isDense: true,
                    contentPadding: EdgeInsets.zero, // Rimuove il padding
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      // Aggiorna la mappa userData con il nuovo valore
                      String label = field['label'];
                      if (label == 'Nome') {
                        userData['firstName'] = newValue;
                      } else if (label == 'Cognome') {
                        userData['lastName'] = newValue;
                      } else if (label == 'Città') {
                        userData['city'] = newValue;
                      } else if (label == 'CAP') {
                        userData['cap'] = newValue;
                      }
                    });
                  },
                )
                    : Text(
                  field['value'].toString(),
                  style: textStyle,
                ),
              ),
            ],
          ),
        );
      }
    }).toList();
  }

  /// Save the user data to Firestore after validation checks.
  Future<bool> _saveUserData() async {
    // Definizione delle espressioni regolari per la validazione
    final RegExp nameRegExp = RegExp(r"^[A-Za-zÀ-ÿ\s']{1,255}$");
    final RegExp streetRegExp = RegExp(r"^[A-Za-zÀ-ÿ\s']{1,255}$");
    final RegExp numberRegExp = RegExp(r"^[A-Za-z0-9/]{1,10}$");
    final RegExp cityRegExp = RegExp(r"^[A-Za-zÀ-ÿ\s']{1,255}$");
    final RegExp capRegExp = RegExp(r"^\d{5}$");

    List<String> errors = [];

    // Estrazione e trim dei valori
    String firstName = (userData['firstName'] ?? '').toString().trim();
    String lastName = (userData['lastName'] ?? '').toString().trim();
    Map<String, dynamic>? address = userData['address'];
    String street = address != null ? (address['street'] ?? '').toString().trim() : '';
    String number = address != null ? (address['number'] ?? '').toString().trim() : '';
    String city = (userData['city'] ?? '').toString().trim();
    String cap = (userData['cap'] ?? '').toString().trim();

    // Controllo non nullità e non vuotezza
    if (firstName.isEmpty) {
      errors.add('Il campo "Nome" non può essere vuoto.');
    }
    if (lastName.isEmpty) {
      errors.add('Il campo "Cognome" non può essere vuoto.');
    }
    if (street.isEmpty) {
      errors.add('Il campo "Via" non può essere vuoto.');
    }
    if (number.isEmpty) {
      errors.add('Il campo "Numero Civico" non può essere vuoto.');
    }
    if (city.isEmpty) {
      errors.add('Il campo "Città" non può essere vuoto.');
    }
    if (cap.isEmpty) {
      errors.add('Il campo "CAP" non può essere vuoto.');
    }

    // Validazione Nome
    if (firstName.isNotEmpty && !nameRegExp.hasMatch(firstName)) {
      errors.add('Il campo "Nome" può contenere solo lettere, spazi e apostrofi (max 255 caratteri).');
    }

    // Validazione Cognome
    if (lastName.isNotEmpty && !nameRegExp.hasMatch(lastName)) {
      errors.add('Il campo "Cognome" può contenere solo lettere, spazi e apostrofi (max 255 caratteri).');
    }

    // Validazione Street
    if (street.isNotEmpty && !streetRegExp.hasMatch(street)) {
      errors.add('Il campo "Via" può contenere solo lettere, spazi, apostrofi e caratteri accentati (max 255 caratteri).');
    }

    // Validazione Numero Civico
    if (number.isNotEmpty && !numberRegExp.hasMatch(number)) {
      errors.add('Il campo "Numero Civico" può contenere solo lettere, numeri e "/" (max 10 caratteri).');
    }

    // Validazione Città
    if (city.isNotEmpty && !cityRegExp.hasMatch(city)) {
      errors.add('Il campo "Città" può contenere solo lettere, spazi e apostrofi (max 255 caratteri).');
    }

    // Validazione CAP
    if (cap.isNotEmpty && !capRegExp.hasMatch(cap)) {
      errors.add('Il campo "CAP" deve essere esattamente composto da 5 cifre.');
    }

    // Se ci sono errori, mostrare un SnackBar con tutti i messaggi di errore
    if (errors.isNotEmpty) {
      String errorMessage = errors.join('\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return false; // Indica che il salvataggio non è riuscito
    }

    // Se tutti i controlli passano, procediamo al salvataggio
    try {
      await userController.updateUserData(userData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dati salvati con successo'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        originalUserData = Map<String, dynamic>.from(userData);
      });
      return true; // Indica che il salvataggio è riuscito
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante il salvataggio: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return false; // Indica che il salvataggio non è riuscito
    }
  }

  Widget _buildProfileHeader(
      ThemeData theme, User user, Map<String, dynamic> userData) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 80,
            backgroundImage:
            user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null ? Icon(Icons.person, size: 80) : null,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Email:',
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                user.email ?? 'N/A',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Password:',
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '********',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Modifica Email',
                    style: const TextStyle(fontSize: 14), // Riduce la dimensione del testo
                  ),
                ),
                onPressed: _showChangeEmailSheet,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Modifica Password',
                    style: const TextStyle(fontSize: 14), // Riduce la dimensione del testo
                  ),
                ),
                onPressed: _showChangePasswordSheet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showChangeEmailSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ChangeEmailSheet(
        onSubmit: (newEmail, currentPassword) async {
          Navigator.of(context).pop();
          await _changeEmail(newEmail, currentPassword);
        },
      ),
    );
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ChangePasswordSheet(
        onSubmit: (currentPassword, newPassword, confirmPassword) async {
          Navigator.of(context).pop();
          await _changePassword(currentPassword, newPassword);
        },
      ),
    );
  }

  Future<void> _changeEmail(String newEmail, String currentPassword) async {
    try {
      await userController.changeEmail(context,
          newEmail: newEmail, currentPassword: currentPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email aggiornata con successo')),
      );
    } catch (e) {
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
            errorMessage = 'La password corrente non è corretta.';
            break;
          default:
            errorMessage = 'Errore: ${e.message}';
        }
      } else {
        errorMessage = 'Si è verificato un errore: $e';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> _changePassword(
      String currentPassword, String newPassword) async {
    try {
      await userController.changePassword(context,
          currentPassword: currentPassword, newPassword: newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password aggiornata con successo'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3)),
      );
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'La nuova password è troppo debole.';
            break;
          case 'wrong-password':
          case 'invalid-credential':
            errorMessage = 'La password corrente non è corretta.';
            break;
          default:
            // errorMessage = 'Errore: ${e.message}';
            errorMessage = 'Si è verificato un errore.';
        }
      } else {
        errorMessage = 'Si è verificato un errore: $e';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5)),
      );
    }
  }
}

/// Widget for the modal sheet to change the email.
class ChangeEmailSheet extends StatefulWidget {
  final Function(String newEmail, String currentPassword) onSubmit;

  const ChangeEmailSheet({required this.onSubmit, Key? key}) : super(key: key);

  @override
  _ChangeEmailSheetState createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends State<ChangeEmailSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeManager().customTheme;

    return Wrap(
      children: [
        Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifica Email',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration:
                      const InputDecoration(labelText: 'Nuova Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci una nuova email';
                        }
                        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Inserisci un\'email valida';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration:
                      const InputDecoration(labelText: 'Password Corrente'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci la password corrente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          await widget.onSubmit(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      child: const Text('Conferma'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget for the modal sheet to change the password.
class ChangePasswordSheet extends StatefulWidget {
  final Function(
      String currentPassword, String newPassword, String confirmPassword)
  onSubmit;

  const ChangePasswordSheet({required this.onSubmit, Key? key})
      : super(key: key);

  @override
  _ChangePasswordSheetState createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeManager().customTheme;

    return Wrap(
      children: [
        Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifica Password',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _currentPasswordController,
                      decoration:
                      const InputDecoration(labelText: 'Password Corrente'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci la password corrente';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Nuova Password',
                        errorMaxLines: 3, // For multiple error messages
                        errorStyle: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        /// Validates the new password.
                        if (value == null || value.isEmpty) {
                          return 'Inserisci una nuova password';
                        }
                        if (value.length < 6) {
                          return 'La password deve essere di almeno 6 caratteri';
                        }
                        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\W)')
                            .hasMatch(value)) {
                          return 'La password deve contenere almeno una lettera maiuscola, una lettera minuscola e un carattere speciale';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                          labelText: 'Conferma Nuova Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value != _newPasswordController.text) {
                          return 'Le password non coincidono';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          await widget.onSubmit(
                            _currentPasswordController.text.trim(),
                            _newPasswordController.text.trim(),
                            _confirmPasswordController.text.trim(),
                          );
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      child: const Text('Conferma'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}