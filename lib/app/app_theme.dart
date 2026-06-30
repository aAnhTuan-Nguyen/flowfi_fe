import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

FThemeData buildForuiTheme() {
  final isTouchPlatform = const {
    TargetPlatform.android,
    TargetPlatform.fuchsia,
    TargetPlatform.iOS,
  }.contains(defaultTargetPlatform);

  return isTouchPlatform
      ? FThemes.neutral.light.touch
      : FThemes.neutral.light.desktop;
}

ThemeData buildAppTheme() {
  const canvas = Color(0xFFFAFBF6);
  const surface = Color(0xFFFFFFFF);
  const surfaceSoft = Color(0xFFF1F5EA);
  const primaryDark = Color(0xFF172015);
  const primaryGreen = Color(0xFF4F6F39);
  const accentGreen = Color(0xFF8BAE66);
  const amber = Color(0xFFC9872B);
  const danger = Color(0xFFB84A3F);
  const muted = Color(0xFF687268);

  final baseTheme = buildForuiTheme().toApproximateMaterialTheme();
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        surface: canvas,
        primary: primaryGreen,
        secondary: accentGreen,
        tertiary: amber,
        error: danger,
      ).copyWith(
        onSurface: primaryDark,
        surfaceContainerLowest: surface,
        surfaceContainerLow: surfaceSoft,
        surfaceContainer: const Color(0xFFE8EFE0),
        surfaceContainerHigh: const Color(0xFFDCE8CF),
        primaryContainer: const Color(0xFFDDECCF),
        onPrimaryContainer: primaryDark,
        secondaryContainer: const Color(0xFFFFE9C2),
        onSecondaryContainer: const Color(0xFF3E2A05),
        outline: const Color(0xFFD9DED4),
        outlineVariant: const Color(0xFFE8ECE2),
      );

  return baseTheme.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: canvas,
    appBarTheme: const AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: primaryDark,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        minimumSize: const Size(0, 44),
        side: const BorderSide(color: Color(0xFFD9DED4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD9DED4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD9DED4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryGreen, width: 1.4),
      ),
      labelStyle: const TextStyle(color: muted, fontWeight: FontWeight.w600),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: const Color(0xFFDDECCF),
      disabledColor: const Color(0xFFF0F2ED),
      side: const BorderSide(color: Color(0xFFD9DED4)),
      labelStyle: const TextStyle(
        color: primaryDark,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: const TextStyle(
        color: primaryDark,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: surface,
      elevation: 8,
      shadowColor: Color(0x1F172015),
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: const Color(0xFFDDECCF),
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
    popupMenuTheme: PopupMenuThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryDark,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 25,
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
    ).apply(fontFamily: 'Be Vietnam Pro'),
  );
}
