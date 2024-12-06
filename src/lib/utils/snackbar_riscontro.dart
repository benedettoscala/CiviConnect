import 'package:flutter/material.dart';

/// Show a snackbar message.
/// The message can be an error message or a success message.
/// Parameters:
/// - [context]: The build context.
/// - [isError]: Whether the message is an error message.
/// - [message]: The message to show.
/// Returns:
/// - A snackbar message.
void showMessage(BuildContext context, {isError = false, message = ''}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 7),
    ),
  );
}
