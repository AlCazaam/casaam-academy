
import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
  ),
  colorScheme: ColorScheme.dark(
    errorContainer: Colors.red, // Changed error color
    background: Colors.black,
    primary: Colors.grey[900]!,
    secondary: Colors.grey[800]!,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade200,
    inverseSurface: Colors.white,

    // Additonal Colors
    primaryContainer: Colors.blueGrey[700],  // Dark blue-grey for containers
    secondaryContainer: Colors.green[700], // Dark green for containers
    onPrimary: Colors.white,      // Text color on primary color
    onSecondary: Colors.grey[200]!,     // Text color on secondary color
    surface: Colors.grey[850]!,     // Background for cards, dialogs
    onSurface: Colors.white,       // Text color on surfaces
    error: Colors.redAccent,       // Error Color
    onError: Colors.white,         // Error Text Color
  ),
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(backgroundColor: Colors.white)),
);