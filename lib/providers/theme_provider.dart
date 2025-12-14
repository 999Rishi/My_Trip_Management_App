import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleThemeMode() {
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
    } else if (state == ThemeMode.dark) {
      state = ThemeMode.system;
    } else {
      state = ThemeMode.light;
    }
  }

  // Update theme based on user preference
  void updateThemeFromUserPreference(User? user) {
    if (user == null) {
      state = ThemeMode.system;
    } else {
      state = user.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
    }
  }
}
