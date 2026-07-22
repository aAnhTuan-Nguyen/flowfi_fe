import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

FThemeData buildForuiTheme([Brightness brightness = Brightness.light]) {
  final isTouchPlatform = const {
    TargetPlatform.android,
    TargetPlatform.fuchsia,
    TargetPlatform.iOS,
  }.contains(defaultTargetPlatform);
  final theme = brightness == Brightness.dark
      ? FThemes.neutral.dark
      : FThemes.neutral.light;

  return isTouchPlatform ? theme.touch : theme.desktop;
}

ThemeData buildAppTheme([Brightness brightness = Brightness.light]) {
  final isDark = brightness == Brightness.dark;
  final canvas = isDark ? const Color(0xFF10130F) : const Color(0xFFFFF8F3);
  final surface = isDark ? const Color(0xFF181C16) : const Color(0xFFFFFFFF);
  final surfaceSoft = isDark
      ? const Color(0xFF22281F)
      : const Color(0xFFFFF1E3);
  final primaryText = isDark
      ? const Color(0xFFF4F1EA)
      : const Color(0xFF172015);
  const primaryGreen = Color(0xFF4F6F39);
  const primaryGreenDark = Color(0xFFA8C982);
  const accentGreen = Color(0xFF8BAE66);
  const amber = Color(0xFFC9872B);
  const danger = Color(0xFFB84A3F);
  final muted = isDark ? const Color(0xFFB9C2B4) : const Color(0xFF687268);
  final outline = isDark ? const Color(0xFF3A4235) : const Color(0xFFD9DED4);
  final outlineVariant = isDark
      ? const Color(0xFF2C342A)
      : const Color(0xFFE8ECE2);
  final primary = isDark ? primaryGreenDark : primaryGreen;

  final baseTheme = buildForuiTheme(brightness).toApproximateMaterialTheme();
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        surface: canvas,
        primary: primary,
        secondary: accentGreen,
        tertiary: amber,
        error: danger,
      ).copyWith(
        onSurface: primaryText,
        surfaceContainerLowest: surface,
        surfaceContainerLow: surfaceSoft,
        surfaceContainer: isDark
            ? const Color(0xFF263021)
            : const Color(0xFFE8EFE0),
        surfaceContainerHigh: isDark
            ? const Color(0xFF303B29)
            : const Color(0xFFDCE8CF),
        primaryContainer: isDark
            ? const Color(0xFF2D4324)
            : const Color(0xFFDDECCF),
        onPrimaryContainer: primaryText,
        secondaryContainer: isDark
            ? const Color(0xFF4A3510)
            : const Color(0xFFFFE9C2),
        onSecondaryContainer: isDark
            ? const Color(0xFFFFE9C2)
            : const Color(0xFF3E2A05),
        outline: outline,
        outlineVariant: outlineVariant,
      );

  return baseTheme.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: canvas,
    appBarTheme: AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: primaryText,
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
        backgroundColor: primary,
        foregroundColor: isDark ? const Color(0xFF172015) : Colors.white,
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryText,
        minimumSize: const Size(0, 44),
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primary, width: 1.4),
      ),
      labelStyle: TextStyle(color: muted, fontWeight: FontWeight.w600),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: colorScheme.primaryContainer,
      disabledColor: colorScheme.surfaceContainer,
      side: BorderSide(color: outline),
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ).copyWith(color: primaryText),
      secondaryLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ).copyWith(color: primaryText),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: isDark ? const Color(0xFF172015) : Colors.white,
      elevation: 6,
      shape: const CircleBorder(),
    ),
    bottomAppBarTheme: BottomAppBarThemeData(
      color: surface,
      elevation: 8,
      shadowColor: isDark ? const Color(0x66000000) : const Color(0x1F172015),
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: colorScheme.primaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected ? primary : muted,
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? primary : muted,
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
      backgroundColor: isDark ? const Color(0xFFF4F1EA) : const Color(0xFF172015),
      contentTextStyle: TextStyle(
        color: isDark ? const Color(0xFF172015) : Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: primaryText,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: primaryText,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: primaryText,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: primaryText,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: primaryText,
      ),
    ).apply(fontFamily: 'Be Vietnam Pro'),
  );
}
