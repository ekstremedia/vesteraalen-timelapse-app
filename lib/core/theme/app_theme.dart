import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme matching ekstremedia.no website aesthetic.
/// Dark mode optimized for viewing camera images and timelapses.
class AppTheme {
  // Primary purple color matching ekstremedia.no website
  static const Color primaryColor = Color(0xFF9D4EDD);
  static const Color primaryLight = Color(0xFFB76EF0);
  static const Color primaryDark = Color(0xFF7B2CBF);

  // Secondary accent colors
  static const Color accentGreen = Color(0xFF22C55E); // Online status
  static const Color accentPurple = Color(0xFF8B5CF6);

  // Surface colors for dark theme - purple/navy matching website
  static const Color surfaceDark = Color(0xFF0D0D1A);
  static const Color surfaceContainerDark = Color(0xFF1A1A2E);
  static const Color surfaceContainerHighDark = Color(0xFF252547);

  // Text colors for dark theme
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onSurfaceVariantDark = Color(0xFFB8B8D0);

  // Surface colors for light theme
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color surfaceContainerLight = Color(0xFFFFFFFF);

  // Text colors for light theme
  static const Color onSurfaceLight = Color(0xFF1F2937);
  static const Color onSurfaceVariantLight = Color(0xFF6B7280);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentPurple,
        tertiary: accentGreen,
        surface: surfaceDark,
        surfaceContainerHighest: surfaceContainerHighDark,
        onSurface: onSurfaceDark,
        onSurfaceVariant: onSurfaceVariantDark,
      ),
      scaffoldBackgroundColor: surfaceDark,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: onSurfaceDark, displayColor: onSurfaceDark),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: true,
        foregroundColor: onSurfaceDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurfaceDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: primaryColor, width: 1.5),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryColor),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: onSurfaceDark),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: DividerThemeData(color: primaryColor.withOpacity(0.2)),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surfaceContainerDark,
        headerBackgroundColor: primaryColor,
        headerForegroundColor: Colors.white,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          if (states.contains(WidgetState.disabled)) {
            return onSurfaceVariantDark.withOpacity(0.4);
          }
          return onSurfaceDark;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        todayForegroundColor: WidgetStateProperty.all(primaryColor),
        todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
        todayBorder: BorderSide(color: primaryColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceContainerDark,
        selectedItemColor: primaryColor,
        unselectedItemColor: onSurfaceVariantDark,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: surfaceContainerHighDark,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        thumbColor: primaryColor,
        inactiveTrackColor: primaryColor.withOpacity(0.3),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryDark,
        secondary: primaryColor,
        surface: surfaceLight,
        onSurface: onSurfaceLight,
        onSurfaceVariant: onSurfaceVariantLight,
      ),
      scaffoldBackgroundColor: surfaceLight,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: onSurfaceLight, displayColor: onSurfaceLight),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceContainerLight,
        elevation: 0,
        centerTitle: true,
        foregroundColor: onSurfaceLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurfaceLight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: primaryDark.withOpacity(0.3)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: onSurfaceLight),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLight,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: DividerThemeData(
        color: onSurfaceVariantLight.withOpacity(0.2),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surfaceContainerLight,
        headerBackgroundColor: primaryDark,
        headerForegroundColor: Colors.white,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          if (states.contains(WidgetState.disabled)) {
            return onSurfaceVariantLight.withOpacity(0.4);
          }
          return onSurfaceLight;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryDark;
          }
          return null;
        }),
        todayForegroundColor: WidgetStateProperty.all(primaryDark),
        todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
        todayBorder: BorderSide(color: primaryDark),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceContainerLight,
        selectedItemColor: primaryDark,
        unselectedItemColor: onSurfaceVariantLight,
      ),
    );
  }
}
