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
      headlineLarge: TextStyle(
        color: AppColors.black,
        fontSize: 26,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: AppColors.black,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: AppColors.black,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      titleSmall: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: AppColors.black,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14.5,
        color: AppColors.black,
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: AppColors.black,
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
      headlineLarge: TextStyle(
        color: AppColors.white,
        fontSize: 26,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: AppColors.white,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: AppColors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      titleSmall: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1.1,
        color: AppColors.white,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14.5,
        height: 1.2,
        color: AppColors.white,
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        height: 1.2,
        color: AppColors.white,
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
