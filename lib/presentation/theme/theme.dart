import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF050505);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color primary = Color(0xFF00FF41); // Neon Green (Matrix)
  static const Color secondary = Color(0xFF00F0FF); // Cyber Blue
  static const Color error = Color(0xFFFF003C); // Cyber Red (Glitch)
  static const Color text = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFF424242);

  static TextTheme get _textTheme => TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primary,
          letterSpacing: 2.0,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: text,
          letterSpacing: 1.5,
        ),
        bodyLarge: GoogleFonts.robotoMono(
          fontSize: 16,
          color: text,
        ),
        bodyMedium: GoogleFonts.robotoMono(
          fontSize: 14,
          color: text.withValues(alpha: 0.8),
        ),
        labelLarge: GoogleFonts.orbitron(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: background,
        ),
      );

  static ThemeData get cyberpunkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: background,
        secondary: secondary,
        onSecondary: background,
        error: error,
        onError: text,
        surface: surface,
        onSurface: text,
      ),
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero, // Brutalist
          borderSide: BorderSide(color: primary.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: primary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: GoogleFonts.robotoMono(color: secondary),
        hintStyle: GoogleFonts.robotoMono(color: disabled),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
          shape: const ContinuousRectangleBorder(), // Sharp edges
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
          elevation: 10,
          shadowColor: primary.withValues(alpha: 0.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: primary.withValues(alpha: 0.2), width: 1),
          borderRadius: BorderRadius.zero,
        ),
        shadowColor: Colors.black,
        elevation: 5,
      ),
    );
  }
}
