import 'package:flutter/material.dart';

/// A singleton class to manage the application's theme.
class ThemeManager {
  ThemeManager._internal();

  /// Singleton instance of [ThemeManager].
  static final ThemeManager _instance = ThemeManager._internal();

  /// Factory constructor to return the singleton instance.
  factory ThemeManager() => _instance;

  /// The seed color used for the theme.
  final Color seedColor = const Color.fromRGBO(0, 69, 118, 1);

  /// The custom theme for the application.
  final ThemeData customTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromRGBO(0, 69, 118, 1),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(0, 69, 118, 1),
      foregroundColor: Colors.white,
      elevation: 4,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.black87,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Colors.black,
        fontSize: 14,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 18,
      ),
      bodySmall: TextStyle(
        color: Colors.black87,
        fontSize: 12,
      ),
      titleSmall: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
  );
}
