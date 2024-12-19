import 'package:flutter/material.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.purpleBright,
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
        backgroundColor: AppColors.yellow,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
          fontSize: 20,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: br30),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: AppColors.yellow,
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
        backgroundColor: AppColors.yellow,
        textStyle: const TextStyle(
          fontSize: 20,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: br30),
      ),
    ),
  );
}
