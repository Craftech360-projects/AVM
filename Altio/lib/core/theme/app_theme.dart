import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(iconColor: WidgetStatePropertyAll(AppColors.black))),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
      iconColor: WidgetStatePropertyAll(AppColors.black),
      textStyle: WidgetStateProperty.all(
        TextStyle(color: AppColors.black, fontFamily: "Montserrat"),
      ),
      foregroundColor: WidgetStateProperty.all(AppColors.black),
    )),
    appBarTheme: AppBarTheme(backgroundColor: AppColors.white),
    iconTheme: IconThemeData(color: AppColors.black),
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
        foregroundColor: AppColors.white,
        backgroundColor: AppColors.purpleDark,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
            fontSize: 17, fontFamily: "Montserrat", color: AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: br12),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: AppColors.purpleDark,
    scaffoldBackgroundColor: AppColors.black,
    iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(iconColor: WidgetStatePropertyAll(AppColors.white))),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
      iconColor: WidgetStatePropertyAll(AppColors.white),
      textStyle: WidgetStateProperty.all(
        TextStyle(color: AppColors.white, fontFamily: "Montserrat"),
      ),
      foregroundColor: WidgetStateProperty.all(AppColors.black),
    )),
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.black),
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
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.purpleDark,
        textStyle: const TextStyle(
          color: AppColors.purpleDark,
          fontSize: 17,
          fontFamily: "Montserrat",
        ),
        shape: RoundedRectangleBorder(borderRadius: br12),
      ),
    ),
  );
}
