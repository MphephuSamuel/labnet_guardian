import 'package:flutter/material.dart';

class AppColors {
  // Gradient Colors
  static const Color gradientStart = Color(0xFF8B5CF6);
  static const Color gradientEnd = Color(0xFFEC4899);

  // Icon Colors
  static const Color iconPurple = Color(0xFF8B5CF6);
  static const Color iconPink = Color(0xFFEC4899);
  static const Color iconBlue = Color(0xFF3B82F6);
 
  // Alert colors
  static const critical = Color(0xFFEF4444);
  static const criticalBg = Color(0xFFFFEBEB);
  static const warning = Color(0xFFF59E0B);
  static const warningBg = Color(0xFFFFF8EB);
  static const info = Color(0xFF3B82F6);
  static const connection = Color(0xFF10B981);

  // Dark Mode
  static const Color darkBg = Color(0xFF0F0F1A);
  static const Color darkCard = Color(0xFF1A1A2E);
  static const Color darkBorder = Color(0xFFFFFFFF);
  static const double darkBorderOpacity = 0.12;

  // Light Mode
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color lightCard = Colors.white;
  static const Color lightBorder = Color(0xFFE5E5EA);

  // Text
  static const Color textLight = Colors.white;
  static const Color textLightSecondary = Colors.white70;
  static const Color textDarkPrimary = Colors.black87;
  static const Color textDarkSecondary = Colors.black54;

  // Utilities
  static const Color dividerDark = Color(0xFFFFFFFF);
  static const double dividerDarkOpacity = 0.12;

  static Color getDarkBgColor() => darkBg;
  static Color getCardColor(bool isDark) => isDark ? darkCard : lightCard;
  static Color getBgColor(bool isDark) => isDark ? darkBg : lightBg;
  static Color getTextPrimary(bool isDark) =>
      isDark ? textLight : textDarkPrimary;
  static Color getTextSecondary(bool isDark) =>
      isDark ? textLightSecondary : textDarkSecondary;
  static Color getBorderColor(bool isDark) =>
      isDark ? darkBorder : lightBorder;
}
