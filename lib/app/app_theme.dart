import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme() {
  const canvas = Color(0xFFFFF8F3);
  const primaryDark = Color(0xFF1B211A);
  const primaryGreen = Color(0xFF628141);
  const accentGreen = Color(0xFF8BAE66);
  const warmSurface = Color(0xFFFFF1E3);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryGreen,
    brightness: Brightness.light,
    surface: canvas,
    primary: primaryGreen,
    secondary: accentGreen,
  ).copyWith(
    onSurface: primaryDark,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: warmSurface,
    surfaceContainer: const Color(0xFFFFEBD3),
    surfaceContainerHigh: const Color(0xFFFFE4C2),
    primaryContainer: primaryDark,
    onPrimaryContainer: Colors.white,
  );

  const baseTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.96,
      height: 56 / 48,
      color: primaryDark,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.32,
      height: 40 / 32,
      color: primaryDark,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 32 / 24,
      color: primaryDark,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: primaryDark,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 24 / 16,
      color: primaryDark,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 28 / 18,
      color: primaryDark,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
      color: primaryDark,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.14,
      height: 20 / 14,
      color: primaryDark,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.24,
      height: 16 / 12,
      color: primaryDark,
    ),
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: canvas,
    appBarTheme: const AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: primaryDark,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE7F1DA),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected ? primaryGreen : const Color(0xFF757872),
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? primaryGreen : const Color(0xFF757872),
          size: 22,
        );
      }),
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTextTheme),
    useMaterial3: true,
  );
}
