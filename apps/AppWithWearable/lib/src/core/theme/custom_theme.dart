import 'package:flutter/material.dart';
import 'package:friend_private/src/core/theme/theme.dart';
import 'package:friend_private/src/core/constant/custom_colors.dart';

class CustomTheme {
  CustomTheme._();

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    chipTheme: AvmChipTheme.lightCardTheme,
    listTileTheme: AvmListTileTheme.lightCardTheme,
    textTheme: AvmTextTheme.lightTextTheme,
    scaffoldBackgroundColor: CustomColors.greyOffWhite,
  );
}
