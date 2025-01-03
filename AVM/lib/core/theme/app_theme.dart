import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    iconTheme: const IconThemeData(color: AppColors.black),
    primaryColor: AppColors.purpleDark,
    brightness: Brightness.light,
    fontFamily: "Montserrat",
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.purpleDark,
        foregroundColor: AppColors.commonPink,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
          fontSize: 20,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: br12),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    iconTheme: const IconThemeData(color: AppColors.white),
    primaryColor: AppColors.white,
    scaffoldBackgroundColor: AppColors.darkBg,
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.darkBg),
    brightness: Brightness.dark,
    fontFamily: "Montserrat",
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.w500,
      ),
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shadowColor: Colors.transparent,
        elevation: 0,
        backgroundColor: AppColors.commonPink,
        foregroundColor: AppColors.purpleDark,
        textStyle: const TextStyle(
          fontSize: 20,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: br12),
      ),
    ),
  );
}
