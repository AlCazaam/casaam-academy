import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
  ),
  colorScheme: ColorScheme.light(
    errorContainer: Colors.red, // Changed error color
    background: Colors.grey[300]!,
    primary: Colors.grey[200]!,
    secondary: Colors.grey[300]!,
    tertiary: Colors.black,
    inversePrimary: Colors.black,
    inverseSurface: Colors.black,

    // Additonal Colors
    primaryContainer: Colors.blue[100],  // Light blue for containers
    secondaryContainer: Colors.green[100], // Light green for containers
    onPrimary: Colors.white,  // Text color on primary color
    onSecondary: Colors.black87, // Text color on secondary color
    surface: Colors.white,     // Background for cards, dialogs
    onSurface: Colors.black87,  // Text color on surfaces
    error: Colors.redAccent,    // For Error Texts
    onError: Colors.white,      // Error Text Color
  ),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(backgroundColor: Colors.black)),
);
