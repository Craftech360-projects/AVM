import 'package:flutter/material.dart';
import 'package:friend_private/core_updated/constants/constants.dart';
import 'package:friend_private/core_updated/theme/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.purpleBright,
    brightness: Brightness.light,
    fontFamily: "Montserrat",
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
