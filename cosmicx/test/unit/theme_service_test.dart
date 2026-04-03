import 'package:cosmicx/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeService unit tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('returns false by default when no saved preference exists', () async {
      final isDark = await ThemeService.isDarkMode();
      expect(isDark, isFalse);
    });

    test('persists and reads dark mode preference', () async {
      await ThemeService.setDarkMode(true);
      final isDark = await ThemeService.isDarkMode();
      expect(isDark, isTrue);
    });

    test('returns ThemeMode.dark when input is true', () {
      expect(ThemeService.getThemeMode(true), equals(ThemeMode.dark));
    });

    test('returns ThemeMode.light when input is false', () {
      expect(ThemeService.getThemeMode(false), equals(ThemeMode.light));
    });
  });
}
