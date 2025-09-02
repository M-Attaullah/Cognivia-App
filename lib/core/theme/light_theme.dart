import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.lightPrimary,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: AppColors.lightBackground,

  // AppBar theme
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.lightSurface,
    foregroundColor: AppColors.lightText,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.lightText,
    ),
  ),

  // Card theme
  cardTheme: CardThemeData(
    color: AppColors.lightSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.lightBorder, width: 1),
    ),
  ),

  // Elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  // Floating action button theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.lightPrimary,
    foregroundColor: Colors.white,
    elevation: 4,
  ),

  // Input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.lightBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.lightBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
    ),
    hintStyle: const TextStyle(color: AppColors.lightSecondaryText),
    labelStyle: const TextStyle(color: AppColors.lightSecondaryText),
  ),

  // Bottom navigation bar theme
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.lightSurface,
    selectedItemColor: AppColors.lightPrimary,
    unselectedItemColor: AppColors.lightSecondaryText,
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
    backgroundColor: AppColors.lightSurface,
    labelStyle: const TextStyle(
      color: AppColors.lightText,
      fontWeight: FontWeight.w600,
    ),
    selectedColor: AppColors.lightSecondary,
    side: const BorderSide(color: AppColors.lightBorder),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  // Text theme
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.lightText,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.lightText,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.lightText,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.lightText,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.lightText,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.lightText),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.lightText),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.lightSecondaryText),
  ),

  // Divider theme
  dividerTheme: const DividerThemeData(
    color: AppColors.lightBorder,
    thickness: 1,
  ),

  // Icon theme
  iconTheme: const IconThemeData(color: AppColors.lightText),
);
