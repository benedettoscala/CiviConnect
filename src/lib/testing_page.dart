import 'package:civiconnect/user_management/user_wrapper.dart';
import 'package:flutter/material.dart';

/// UI page for testing login functionality.
class TestingPage extends StatelessWidget {
  final UserWrapper _user;

  /// Constructs a new instance of [TestingPage].
  const TestingPage({required user, super.key}) : _user = user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing Page'),
      ),
      body: Text(_user.email),
    );
  }
}
