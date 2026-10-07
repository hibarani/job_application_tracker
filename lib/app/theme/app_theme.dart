import 'package:flutter/material.dart';

/// Centralized application theme definitions for Material 3.
class AppTheme {
  AppTheme._();

  // Premium Dark Productivity App Palette
  static const Color darkBackground = Color(0xFF10152B); // App Background
  static const Color darkSurface = Color(0xFF3B3475); // PRIMARY CARDS
  static const Color cardBorder = Color(0xFF4A4380); // Card Border
  static const Color primaryAccent = Color(
    0xFFFF8A65,
  ); // Primary Orange/Coral Accent
  static const Color secondaryAccent = Color(0xFF8175D6); // Secondary Violet
  static const Color supportingAccent = Color(0xFFE5B866); // Soft Amber
  static const Color textPrimary = Color(0xFFF7F3EA); // Warm Ivory
  static const Color textSecondary = Color(0xFFB8B5CC); // Muted Lavender Gray

  static const double borderRadius = 16.0;

  /// Light theme definition.
  static ThemeData get lightTheme {
    return _buildTheme(
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.light,
        surface: const Color(0xFFF9FAFB),
        onSurface: const Color(0xFF1F2937),
      ),
    );
  }

  /// Dark theme definition.
  static ThemeData get darkTheme {
    return _buildTheme(
      const ColorScheme.dark(
        primary: primaryAccent,
        secondary: secondaryAccent,
        tertiary: supportingAccent,
        surface: darkBackground,
        onSurface: textPrimary,
      ).copyWith(
        surfaceContainerHighest: darkSurface,
        onSurfaceVariant: textSecondary,
        outlineVariant: cardBorder,
        outline: cardBorder,
        surfaceContainer: darkSurface,
      ),
    );
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

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
            color: isDark
                ? colorScheme.outlineVariant
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
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
        backgroundColor: isDark ? colorScheme.surface : colorScheme.surface,
        indicatorColor: isDark
            ? colorScheme.secondary
            : colorScheme.primary.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: isDark ? colorScheme.onSurface : colorScheme.primary,
            );
          }
          return IconThemeData(
            color: isDark
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            );
          }
          return TextStyle(color: colorScheme.onSurfaceVariant);
        }),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }
}
