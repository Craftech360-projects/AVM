import 'package:altio/backend/preferences.dart';
import 'package:altio/core/assets/app_images.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildPopupContent(
  StateSetter setState,
  bool switchValue,
  void Function(bool) setValue,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        'Enable to get real time\nresponses from Altio AI',
        maxLines: 2,
        style: TextStyle(fontSize: 14),
      ),
      w8,
      Transform.scale(
        scale: 0.8,
        child: Switch(
          inactiveTrackColor: AppColors.white,
          activeTrackColor: AppColors.purpleDark,
          activeColor: AppColors.commonPink,
          activeThumbImage: const AssetImage(AppImages.appLogo),
          value: switchValue,
          onChanged: (value) {
            SharedPreferencesUtil().notificationPlugin = value;
            setState(() {
              setValue(value);
            });
          },
        ),
      ),
    ],
  );
}
