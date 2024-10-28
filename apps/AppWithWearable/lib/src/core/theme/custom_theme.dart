import 'package:flutter/material.dart';
import 'package:friend_private/src/core/theme/theme.dart';

class CustomTheme {
  CustomTheme._();

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    chipTheme: AvmChipTheme.lightCardTheme,
    listTileTheme: AvmListTileTheme.lightCardTheme,
    textTheme: AvmTextTheme.lightTextTheme,
    scaffoldBackgroundColor: Colors.transparent,
    // appBarTheme: const AppBarTheme(
    //   backgroundColor: Colors.transparent,
    //   elevation: 0,
    //   scrolledUnderElevation: 0,
    //   shadowColor: Colors.transparent,
    //   surfaceTintColor: Colors.transparent,
    // ),
  );
}
