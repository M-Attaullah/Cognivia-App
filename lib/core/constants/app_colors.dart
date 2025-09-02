import 'package:flutter/material.dart';

class AppColors {
  // Light Mode - Clean & Professional (YOUR EXACT COLORS)
  static const lightPrimary = Color(0xFF6A11CB); // Solid purple
  static const lightAccent = Color(0xFF667eea); // Soft blue
  static const lightSecondary = Color(
    0xFF8B5CF6,
  ); // Medium purple for secondary elements
  static const lightTertiary = Color(
    0xFF3B82F6,
  ); // Different blue for tertiary elements
  static const lightBackground = Color(0xFFF9FAFB); // Very light gray
  static const lightSurface = Color(0xFFFFFFFF); // White cards/surfaces
  static const lightText = Color(0xFF1F2937); // Dark text
  static const lightSecondaryText = Color(0xFF6B7280); // Gray text
  static const lightBorder = Color(0xFFE5E7EB); // Light borders

  // Alias for compatibility with existing screens
  static const primaryPurple = lightPrimary;

  // Dark Mode - Clean & Modern (YOUR EXACT COLORS)
  static const darkPrimary = Color(0xFF6A11CB); // Same purple for consistency
  static const darkAccent = Color(0xFF667eea); // Same blue for consistency
  static const darkSecondary = Color(
    0xFF8B5CF6,
  ); // Medium purple for secondary elements
  static const darkTertiary = Color(
    0xFF3B82F6,
  ); // Different blue for tertiary elements
  static const darkBackground = Color(0xFF121212); // True dark
  static const darkSurface = Color(0xFF1E293B); // Dark blue-gray cards
  static const darkText = Color(0xFFE5E7EB); // Light text
  static const darkSecondaryText = Color(0xFF9CA3AF); // Gray text
  static const darkBorder = Color(0xFF374151); // Dark borders

  // Gradient colors (ONLY for logo, CTA buttons) - YOUR EXACT GRADIENTS
  static const gradientStart = Color(0xFF6A11CB); // Purple
  static const gradientEnd = Color(0xFF667eea); // Blue
  static const accentGradientStart = Color(0xFF667eea); // Blue
  static const accentGradientEnd = Color(0xFFf093fb); // Pink
}
