// In lib/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // --- Primary Color ---
  static const Color primary = Color.fromARGB(255, 55, 54, 78); // A deep, modern purple

  // --- Dark Theme Colors ---
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E); // For cards, dialogs
  static const Color surfaceVariantDark = Color(0xFF2C2C2C); // Slightly lighter surfaces
  
  static const Color textDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFB0B0B0); // For subtitles, hints

  static const Color outlineDark = Color(0xFF444444);

  // --- General ---
  static const Color error = Color(0xFFCF6679);
}