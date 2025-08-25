import 'package:flutter/material.dart';
import 'package:chat_app/theme/theme1/app_colors.dart';

class AppTextStyles {

  static const String fontFamily = 'Lexend';

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: AppColors.textDark,
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