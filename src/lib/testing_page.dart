import 'package:civiconnect/user_management/user_wrapper.dart';
import 'package:flutter/material.dart';

class TestingPage extends StatelessWidget {
  const TestingPage({required this.user, super.key});
  final UserWrapper user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(user.email),
    );
  }
}
