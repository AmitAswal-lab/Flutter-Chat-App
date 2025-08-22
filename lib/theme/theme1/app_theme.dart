import 'package:flutter/material.dart';
import 'package:chat_app/theme/theme1/app_colors.dart';
import 'package:chat_app/theme/theme1/app_text_styles.dart';

class AppTheme {
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      
      // 1. Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textDark,
        error: AppColors.error,
      ),

      // 2. Text Theme
      textTheme: const TextTheme(
        bodyMedium: AppTextStyles.bodyMedium,
        headlineSmall: AppTextStyles.headlineSmall,
      ),
      
      // 3. Component Themes
      cardTheme: CardThemeData(
        color: Colors.transparent, // Keeping your transparent card style
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.all(20),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantDark,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),

        floatingLabelBehavior: FloatingLabelBehavior.always, 
        
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
      ),
    );
  }
}