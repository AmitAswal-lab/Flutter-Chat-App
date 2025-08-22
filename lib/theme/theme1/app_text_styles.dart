// In lib/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:chat_app/theme/theme1/app_colors.dart';

class AppTextStyles {
  // For this to work, you'd need to add the 'Lexend' font to your project.
  // For now, it will fall back to the default font.
  static const String fontFamily = 'Lexend';

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: AppColors.textDark, // Set the default text color
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}