import 'package:flutter/material.dart';

class AppTheme {
  static const lime = Color(0xFFB8F35A);
  static const graphite = Color(0xFF15171A);
  static const surface = Color(0xFF202328);
  static const surfaceAlt = Color(0xFF2A2E35);
  static const danger = Color(0xFFFF6B6B);

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: lime,
      brightness: Brightness.dark,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: graphite,
      colorScheme: colorScheme.copyWith(
        primary: lime,
        secondary: const Color(0xFF67D8EF),
        error: danger,
        surface: surface,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF30343B)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF111316),
        indicatorColor: lime.withOpacity(0.18),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
