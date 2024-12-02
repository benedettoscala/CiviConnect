import 'package:flutter/material.dart';

import '../theme.dart';

/// A modal sheet widget for changing the user's email.
///
/// This widget allows the user to input a new email and their current password
/// to confirm the email change. It validates the inputs before calling the
/// `onSubmit` function.
class ChangeEmailSheet extends StatefulWidget {
  /// Callback function that is triggered when the form is submitted.
  ///
  /// - [newEmail]: The new email entered by the user.
  /// - [currentPassword]: The current password entered by the user.
  final Function(String newEmail, String currentPassword) onSubmit;

  /// Creates a [ChangeEmailSheet].
  ///
  /// The [onSubmit] callback is required.
  const ChangeEmailSheet({required this.onSubmit, super.key});

  @override
  State<ChangeEmailSheet> createState() => _ChangeEmailSheetState();
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
            right: 16,
          ),
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
                                setState(() => _isLoading = true);
                                await widget.onSubmit(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                                setState(() => _isLoading = false);
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

/// A modal sheet widget for changing the user's password.
///
/// This widget allows the user to input their current password, a new password,
/// and a confirmation for the new password. It validates the inputs before
/// calling the `onSubmit` function.
class ChangePasswordSheet extends StatefulWidget {
  /// Callback function that is triggered when the form is submitted.
  ///
  /// - [currentPassword]: The user's current password.
  /// - [newPassword]: The new password entered by the user.
  /// - [confirmPassword]: The confirmation of the new password entered by the user.
  final Function(
          String currentPassword, String newPassword, String confirmPassword)
      onSubmit;

  /// Creates a [ChangePasswordSheet].
  ///
  /// The [onSubmit] callback is required.
  const ChangePasswordSheet({required this.onSubmit, super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
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
            right: 16,
          ),
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
                        errorMaxLines: 3,
                        errorStyle: TextStyle(fontSize: 12),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci una nuova password';
                        }
                        if (value.length < 6) {
                          return 'La password deve essere di almeno 6 caratteri';
                        }
                        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\W)')
                            .hasMatch(value)) {
                          return 'La password deve contenere almeno una lettera maiuscola, una minuscola e un carattere speciale';
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
                                setState(() => _isLoading = true);
                                await widget.onSubmit(
                                  _currentPasswordController.text.trim(),
                                  _newPasswordController.text.trim(),
                                  _confirmPasswordController.text.trim(),
                                );
                                setState(() => _isLoading = false);
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
