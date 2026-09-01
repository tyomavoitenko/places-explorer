import 'package:flutter/material.dart';

/// Central Material 3 theme. Intentionally minimal: a single seed colour drives
/// the whole scheme so the app stays visually consistent without a design system.
abstract final class AppTheme {
  static const _seed = Color(0xFF00696D);

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }
}
