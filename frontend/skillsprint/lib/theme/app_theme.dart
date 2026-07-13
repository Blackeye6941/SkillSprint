import 'package:flutter/material.dart';

class AppTheme {
  // Pure Black & Dark Charcoal Backgrounds
  static const Color darkBackground = Color(0xFF070707);
  static const Color darkCard = Color(0xFF141414);
  static const Color glassBorder = Color(0xFF262626);

  // Gamified & Brand Colors (Orange & Gold Focus)
  static const Color primaryOrange = Color(0xFFFF9100);
  static const Color primaryOrangeDark = Color(0xFFCC7200);
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color redAccent = Color(0xFFFF4B4B);
  static const Color greenAccent = Color(0xFF00E676);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryOrange,
        secondary: goldAccent,
        surface: darkCard,
        error: redAccent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: glassBorder, width: 1),
        ),
        elevation: 4,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: Colors.white70,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: Colors.white60,
          fontSize: 13,
        ),
      ),
    );
  }
}
