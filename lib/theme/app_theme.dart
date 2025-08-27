import 'package:flutter/material.dart';

class AppTheme {
  // ========================
  // Colors
  // ========================
  static const Color primaryColor = Color(0xFF42A5F5); // A more vibrant blue
  static const Color accentColor = Color(
    0xFF81C784,
  ); // A pop of green for accents
  static const Color secondaryColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color suspendedColor = Color(
    0xFFE57373,
  ); // A slightly deeper red for suspension
  static const Color attendancePresent = Color(0xFF66BB6A); // Green for present
  static const Color attendanceAbsent = Color(0xFFEF5350); // Red for absent
  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color background = Color(
    0xFFF0F4F8,
  ); // A light, neutral background

  // ========================
  // Text Styles
  // ========================
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'Roboto', // Use a common system font
  );

  static const TextStyle subHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: 'Roboto',
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: textSecondary,
    fontFamily: 'Roboto',
  );

  static const TextStyle suspendedText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: suspendedColor,
    fontFamily: 'Roboto',
  );

  static const TextStyle attendanceText = TextStyle(
    fontSize: 14,
    color: textSecondary,
    fontFamily: 'Roboto',
  );

  static const TextStyle studentTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    fontFamily: 'Roboto',
  );

  // ========================
  // Buttons
  // ========================
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: secondaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    elevation: 8,
    shadowColor: primaryColor.withOpacity(0.4),
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
  );

  static ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    side: const BorderSide(color: primaryColor, width: 2),
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
  );

  // ========================
  // Card & Container Decorations
  // ========================
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: textPrimary.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static BoxDecoration suspendedCardDecoration = BoxDecoration(
    color: suspendedColor,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.red.withOpacity(0.2),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static var headerText;
}
