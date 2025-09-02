import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.darkPrimary,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: AppColors.darkBackground,

  // AppBar theme
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkSurface,
    foregroundColor: AppColors.darkText,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
    ),
  ),

  // Card theme
  cardTheme: CardThemeData(
    color: AppColors.darkSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.darkBorder, width: 1),
    ),
  ),

  // Elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  // Floating action button theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.darkPrimary,
    foregroundColor: Colors.white,
    elevation: 4,
  ),

  // Input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
    ),
    hintStyle: const TextStyle(color: AppColors.darkSecondaryText),
    labelStyle: const TextStyle(color: AppColors.darkSecondaryText),
  ),

  // Bottom navigation bar theme
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkSurface,
    selectedItemColor: AppColors.darkPrimary,
    unselectedItemColor: AppColors.darkSecondaryText,
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
    unselectedLabelStyle: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 11,
    ),
  ),

  // Chip theme
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.darkSurface,
    labelStyle: const TextStyle(
      color: AppColors.darkText,
      fontWeight: FontWeight.w600,
    ),
    selectedColor: AppColors.darkSecondary,
    side: const BorderSide(color: AppColors.darkBorder),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  // Text theme
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.darkText,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.darkText,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.darkText,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.darkText),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.darkText),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.darkSecondaryText),
  ),

  // Divider theme
  dividerTheme: const DividerThemeData(
    color: AppColors.darkBorder,
    thickness: 1,
  ),

  // Icon theme
  iconTheme: const IconThemeData(color: AppColors.darkText),
);
