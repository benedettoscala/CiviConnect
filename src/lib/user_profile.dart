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
        originalUserData = Map<String, dynamic>.from(data);
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
                    onPressed: () {
                      setState(() {
                        if (isEditing) {
                          _saveUserData();
                        }
                        isEditing = !isEditing;
                      });
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

  /// Save the user data to Firestore.
  Future<void> _saveUserData() async {
    try {
      await userController.updateUserData(userData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dati salvati con successo')),
      );
      setState(() {
        isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il salvataggio: $e')),
      );
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

  List<Widget> _buildPersonalData(
      Map<String, dynamic> userData, ThemeData theme) {
    final List<Map<String, String>> personalFields = [
      {'Nome': userData['firstName'] ?? 'N/A'},
      {'Cognome': userData['lastName'] ?? 'N/A'},
      {
        'Indirizzo':
        userData['address'] != null ? userData['address']['street'] ?? 'N/A' : 'N/A'
      },
      {'Città': userData['city'] ?? 'N/A'},
      {'CAP': userData['cap'] ?? 'N/A'},
    ];

    TextStyle textStyle = theme.textTheme.titleMedium!.copyWith(fontSize: 16);

    return personalFields
        .map(
          (field) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '${field.keys.first}:',
                style: textStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 3,
              child: isEditing
                  ? TextFormField(
                initialValue: field.values.first,
                style: textStyle.copyWith(
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (newValue) {
                  setState(() {
                    // Aggiorna la mappa userData con il nuovo valore
                    String key = field.keys.first;
                    if (key == 'Nome') {
                      userData['firstName'] = newValue;
                    } else if (key == 'Cognome') {
                      userData['lastName'] = newValue;
                    } else if (key == 'Indirizzo') {
                      if (userData['address'] == null) {
                        userData['address'] = {};
                      }
                      userData['address']['street'] = newValue;
                    } else if (key == 'Città') {
                      userData['city'] = newValue;
                    } else if (key == 'CAP') {
                      userData['cap'] = newValue;
                    }
                  });
                },
              )
                  : Text(
                field.values.first,
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    )
        .toList();
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
        const SnackBar(content: Text('Password aggiornata con successo')),
      );
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'La nuova password è troppo debole.';
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