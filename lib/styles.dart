import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF0A73FF);
  static const Color secondaryColor = Color(0xFFF5A623);
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color textColor = Color(0xFF333333);
  static const Color errorColor = Color(0xFFE57373);
}

class AppTextStyles {
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textColor,
  );
}

ThemeData appTheme(BuildContext context) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primaryColor,
    brightness: Brightness.light,
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headlineLarge,
      bodyLarge: AppTextStyles.bodyLarge,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      titleTextStyle: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
}
