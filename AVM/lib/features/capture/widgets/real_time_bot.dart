import 'package:avm/backend/preferences.dart';
import 'package:avm/core/assets/app_images.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildPopupContent(
  StateSetter setState,
  bool switchValue,
  void Function(bool) setValue,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Enable to get real time\nresponses from the bot',
        maxLines: 2,
        style: TextStyle(fontSize: 14),
      ),
      w10,
      Switch(
        activeTrackColor: AppColors.purpleDark,
        activeColor: AppColors.commonPink,
        activeThumbImage: AssetImage(AppImages.appLogo),
        value: switchValue,
        onChanged: (value) {
          SharedPreferencesUtil().notificationPlugin = value;
          setState(() {
            setValue(value);
          });
        },
      ),
    ],
  );
}