import 'package:flutter/material.dart';

/// Centralized application theme definitions for Material 3.
class AppTheme {
  AppTheme._();

  // Premium Dark Productivity App Palette
  static const Color darkBackground = Color(0xFF17182F); // Deep Indigo-Navy
  static const Color darkSurface = Color(0xFF211F42); // Rich Indigo
  static const Color primaryAccent = Color(0xFFE9785B); // Muted Coral
  static const Color secondaryAccent = Color(0xFF7167B5); // Soft Violet-Indigo
  static const Color supportingAccent = Color(0xFFE5B866); // Soft Amber
  static const Color textPrimary = Color(0xFFF4F0E8); // Warm Ivory
  static const Color textSecondary = Color(0xFFAAA8BC); // Muted Lavender Gray

  static const double borderRadius = 16.0;

  /// Light theme definition.
  static ThemeData get lightTheme {
    return _buildTheme(
      ColorScheme.fromSeed(
        seedColor: primaryAccent,
        brightness: Brightness.light,
        surface: const Color(0xFFF9FAFB),
        onSurface: const Color(0xFF1F2937),
      ),
    );
  }

  /// Dark theme definition.
  static ThemeData get darkTheme {
    return _buildTheme(
      ColorScheme.fromSeed(
        seedColor: primaryAccent,
        brightness: Brightness.dark,
        surface: darkBackground,
        onSurface: textPrimary,
      ).copyWith(
        surfaceContainerHighest: darkSurface,
        onSurfaceVariant: textSecondary,
        primary: primaryAccent,
        secondary: secondaryAccent,
        tertiary: supportingAccent,
      ),
    );
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 2,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.2),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }
}
