import 'package:flutter/material.dart';

class AppTheme {
  static const cloudGray = Color(0xFFF0F0F3);
  static const pureWhite = Color(0xFFFFFFFF);
  static const expoBlack = Color(0xFF000000);
  static const nearBlack = Color(0xFF1C2024);
  static const slateGray = Color(0xFF60646C);
  static const borderLavender = Color(0xFFE0E1E6);
  static const inputBorder = Color(0xFFD9D9E0);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cloudGray,
      colorScheme: const ColorScheme.light(
        primary: expoBlack,
        surface: pureWhite,
        onPrimary: pureWhite,
        onSurface: nearBlack,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: cloudGray,
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLavender),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cloudGray,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: expoBlack,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: expoBlack,
        ),
        centerTitle: true,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: pureWhite,
        indicatorColor: cloudGray,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          height: 1.05,
          letterSpacing: -1.3,
          color: expoBlack,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: -0.6,
          color: expoBlack,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: nearBlack,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: nearBlack),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: slateGray),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: pureWhite,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: expoBlack),
        ),
      ),
    );
  }
}
