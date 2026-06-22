import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const canvas = Color(0xFFFFF8F3);
  const primaryDark = Color(0xFF1B211A);
  const primaryGreen = Color(0xFF628141);
  const accentGreen = Color(0xFF8BAE66);
  const warmSurface = Color(0xFFFFF1E3);

  final colorScheme =
      ColorScheme.fromSeed(
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

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: canvas,
    fontFamily: 'Plus Jakarta Sans',
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
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
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
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: primaryDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: primaryDark,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: primaryDark,
      ),
    ),
    useMaterial3: true,
  );
}
