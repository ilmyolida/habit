import 'package:flutter/material.dart';

class ThemeHelper {
  static ThemeData getLightTheme(int primaryColor) {
    return ThemeData(
      primaryColor: Color(primaryColor),
      colorScheme: ColorScheme.light(
        primary: Color(primaryColor),
        secondary: const Color(0xFF7C4DFF),
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      fontFamily: 'Inter',
      useMaterial3: true,
    );
  }
  
  static ThemeData getDarkTheme(int primaryColor) {
    return ThemeData(
      primaryColor: Color(primaryColor),
      colorScheme: ColorScheme.dark(
        primary: Color(primaryColor),
        secondary: const Color(0xFF7C4DFF),
        surface: const Color(0xFF1E1E1E),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      fontFamily: 'Inter',
      useMaterial3: true,
    );
  }
}