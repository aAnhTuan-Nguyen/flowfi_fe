import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Color seedColor;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.seedColor = const Color(0xFF006E2F), // Default Green
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

class ThemeProvider extends Notifier<ThemeState> {
  static const _themeModeKey = 'themeMode';
  static const _seedColorKey = 'seedColor';

  @override
  ThemeState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    
    final modeString = prefs.getString(_themeModeKey);
    ThemeMode mode = ThemeMode.system;
    if (modeString == 'light') mode = ThemeMode.light;
    else if (modeString == 'dark') mode = ThemeMode.dark;
    
    final colorValue = prefs.getInt(_seedColorKey);
    Color color = const Color(0xFF006E2F);
    if (colorValue != null) {
      color = Color(colorValue);
    }
    
    return ThemeState(themeMode: mode, seedColor: color);
  }

  void toggleTheme(bool isDark) {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    state = state.copyWith(themeMode: newMode);
    ref.read(sharedPreferencesProvider).setString(_themeModeKey, newMode.name);
  }

  void setSeedColor(Color color) {
    state = state.copyWith(seedColor: color);
    ref.read(sharedPreferencesProvider).setInt(_seedColorKey, color.value);
  }
}

final themeProvider = NotifierProvider<ThemeProvider, ThemeState>(() {
  return ThemeProvider();
});
