import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.lightBlue,
  scaffoldBackgroundColor: Colors.lightBlue,
  iconTheme: IconThemeData(color: const Color.fromARGB(255, 60, 35, 103)),

  colorScheme: ColorScheme.light(
    primary: Colors.lightBlue,
    secondary: Colors.blueAccent,
    background: Colors.white,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.black87,
    onSurface: Colors.black87,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.lightBlue,
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.lightBlue,
    foregroundColor: Colors.white,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.lightBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.lightBlue,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
  ),
);
