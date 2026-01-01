import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme matching ekstremedia.no website aesthetic.
/// Dark mode optimized for viewing camera images and timelapses.
class AppTheme {
  // Primary teal color matching ekstremedia.no
  static const Color primaryColor = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF009688);

  // Surface colors for dark theme - optimized for image viewing
  static const Color surfaceDark = Color(0xFF0F1419);
  static const Color surfaceContainerDark = Color(0xFF1A1F26);
  static const Color surfaceContainerHighDark = Color(0xFF252B33);

  // Text colors for dark theme
  static const Color onSurfaceDark = Color(0xFFE8EAED);
  static const Color onSurfaceVariantDark = Color(0xFFB0B8C1);

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
        secondary: primaryColor,
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
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurfaceDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: primaryColor.withOpacity(0.4)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: onSurfaceDark),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerDark,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: DividerThemeData(
        color: onSurfaceVariantDark.withOpacity(0.2),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surfaceContainerDark,
        headerBackgroundColor: primaryColor,
        headerForegroundColor: Colors.black,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.black;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
