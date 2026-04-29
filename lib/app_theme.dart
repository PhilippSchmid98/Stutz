import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. Farben definieren (Palette)
  static const Color primary = Color(0xFF006565);
  static const Color primaryContainer = Color(0xFF008080);
  static const Color secondary = Color(0xFF005FAF);
  static const Color tertiary = Color(0xFFFBBC00); // Warning
  static const Color error = Color(0xFFBA1A1A);

  // Surfaces
  static const Color surface = Color(0xFFFBF9F9); // Base
  static const Color surfaceContainerLow = Color(0xFFF5F3F3); // Sectioning
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // Cards
  static const Color surfaceContainerHigh = Color(0xFFE9E8E7); // Expanded Rows
  static const Color surfaceContainerHighest = Color(
    0xFFE3E2E2,
  ); // Progress Track

  // Text & Icons
  static const Color onBackground = Color(0xFF1B1C1C); // Kein reines Schwarz
  static const Color onSurfaceVariant = Color(0xFF3E4949); // Labels, "CHF"
  static const Color outlineVariant = Color(0xFFBDC9C8); // Ghost Border

  // 2. ThemeData generieren
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        tertiary: tertiary,
        error: error,
        surface: surface,
        onSurface: onBackground,
        onSurfaceVariant: onSurfaceVariant,
        outlineVariant: outlineVariant,

        surfaceContainerLowest: surfaceContainerLowest,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
      ),

      // 3. Typografie (Editorial Scale)
      textTheme: TextTheme(
        // Authoritative Voice (Manrope)
        displayLarge: GoogleFonts.manrope(
          color: onBackground,
          fontSize: 57,
          letterSpacing: -1.14, // -2% Tracking
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.manrope(
          color: onBackground,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.manrope(
          color: onBackground,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.manrope(
          color: onBackground,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),

        // Functional Voice (Inter)
        bodyLarge: GoogleFonts.inter(color: onBackground, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: onBackground, fontSize: 14),
        labelMedium: GoogleFonts.inter(
          color: onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: GoogleFonts.inter(
          color: onSurfaceVariant,
          fontSize: 11,
          letterSpacing: 1.0, // 1px letter-spacing für Metadata
          fontWeight: FontWeight.w600,
        ),
      ),

      // 4. "No-Line" & "No Ripple" Rules anwenden
      dividerColor: Colors.transparent, // Keine globalen 1px Linien
      splashFactory: NoSplash.splashFactory, // Keine Material Ripples
      highlightColor: Colors.transparent, // Kein Highlight-Feedback
      // Card Standard-Verhalten überschreiben
      cardTheme: const CardThemeData(
        elevation: 0, // Depth wird durch Tonal Layering erreicht
        color: surfaceContainerLowest,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)), // rounded-lg
        ),
      ),
    );
  }
}
