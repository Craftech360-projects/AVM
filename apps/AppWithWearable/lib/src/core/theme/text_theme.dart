import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/src/core/constant/custom_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AvmTextTheme {
  AvmTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    bodySmall: GoogleFonts.roboto(
      color: CustomColors.blackPrimary,
      fontWeight: FontWeight.normal,
      fontSize: 12.h,
    ),
    bodyMedium: GoogleFonts.roboto(
      color: CustomColors.blackPrimary,
      fontWeight: FontWeight.normal,
      fontSize: 14.h,
    ),
    bodyLarge: GoogleFonts.roboto(
      color: CustomColors.blackPrimary,
      fontWeight: FontWeight.normal,
      fontSize: 16.h,
    ),
    titleSmall: GoogleFonts.roboto(
      color: CustomColors.blackPrimary,
      fontWeight: FontWeight.normal,
      fontSize: 14.h,
    ),
    labelMedium: GoogleFonts.roboto(
      color: CustomColors.blackPrimary,
      fontWeight: FontWeight.normal,
      fontSize: 12.h,
    ),
    titleMedium: GoogleFonts.roboto(
      color: CustomColors.blackPrimary,
      fontWeight: FontWeight.normal,
      fontSize: 16.h,
    ),
    titleLarge: GoogleFonts.roboto(
      color: CustomColors.blackPrimary,
      fontWeight: FontWeight.normal,
      fontSize: 22.h,
    ),
    headlineSmall: GoogleFonts.roboto(
      color: CustomColors.blackPrimary,
      fontWeight: FontWeight.normal,
      fontSize: 24.h,
    ),
    headlineMedium: GoogleFonts.roboto(
      color: CustomColors.blackPrimary,
      fontWeight: FontWeight.normal,
      fontSize: 28.h,
    ),
    headlineLarge: GoogleFonts.roboto(
      color: CustomColors.blackPrimary,
      fontWeight: FontWeight.normal,
      fontSize: 32.h,
    ),
    displaySmall: GoogleFonts.roboto(
      color: CustomColors.blackPrimary,
      fontWeight: FontWeight.normal,
      fontSize: 36.h,
    ),
  );
}
