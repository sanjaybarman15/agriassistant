import 'package:flutter/material.dart';

class ThemeConstants {
  // Primary Colors
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color primaryYellow = Color(0xFFFFD700);

  // Text Colors
  static const Color textPrimary = primaryBlack;
  static const Color textSecondary = primaryWhite;

  // Background Colors
  static const Color backgroundPrimary = primaryWhite;
  static const Color backgroundSecondary = primaryBlack;

  // Accent Colors
  static const Color accentColor = Color(0xFFFFD700);

  // Text Styles
  static TextStyle get headingStyle => const TextStyle(
        fontFamily: 'InterTight',
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get bodyStyle => const TextStyle(
        fontFamily: 'InterTight',
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: -0.2,
      );

  // Theme Data
  static ThemeData get lightTheme => ThemeData(
        primaryColor: primaryBlack,
        scaffoldBackgroundColor: backgroundPrimary,
        fontFamily: 'InterTight',
        colorScheme: const ColorScheme.light(
          primary: primaryBlack,
          secondary: Color(0xFFFFD700),
          surface: primaryWhite,
          background: primaryWhite,
          error: Color.fromARGB(255, 255, 0, 0),
        ),
        textTheme: TextTheme(
          displayLarge:
              headingStyle.copyWith(fontSize: 32, fontWeight: FontWeight.w700),
          displayMedium:
              headingStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
          displaySmall:
              headingStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
          headlineMedium:
              headingStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
          bodyLarge: bodyStyle.copyWith(fontSize: 18),
          bodyMedium: bodyStyle.copyWith(fontSize: 16),
          bodySmall: bodyStyle.copyWith(fontSize: 14),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryBlack,
          foregroundColor: primaryWhite,
          titleTextStyle: headingStyle.copyWith(
            color: primaryWhite,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
