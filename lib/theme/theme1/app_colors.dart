import 'package:flutter/material.dart';

class AppColors {
 static const Color primary = Color.fromARGB(255, 104, 159, 214); 

 
  static const Color backgroundDark = Color(0xFF121212); 
  static const Color surfaceDark = Color(0xFF1E1E1E); 
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  static const List<Color> chatUsernameColors = [
    Color(0xFF8BC34A), // Light Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFFC107), // Amber
    Color(0xFFE91E63), // Pink
    Color(0xFF00BCD4), // Cyan
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
  ];


  static const Color textDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  static const Color outlineDark = Color(0xFF444444);

  static const Color chatMeBubbleDark = Color(0xFF075E54); // Deep green for 'my' messages (primary color)
  static const Color chatOtherBubbleDark = Color(0xFF262D31); // Dark gray for 'other' messages
  static const Color chatBubbleTextDark = Colors.white; // White text for messages and usernames

  static const Color error = Color(0xFFCF6679);

  static const Color chatMeBubbleLightBlue = Color(0xFF64B5F6);
  static const Color chatBubbleTextLight = Colors.black87;
}
