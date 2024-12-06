import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/core_updated/assets/app_images.dart';
import 'package:friend_private/core_updated/theme/app_colors.dart';
import 'package:friend_private/features/capture/widgets/battery_indicator.dart';
import 'package:friend_private/pages/settings/presentation/pages/setting_page.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';

//Height & Width
const w5 = SizedBox(
  width: 05,
);
const w10 = SizedBox(
  width: 10,
);
const w15 = SizedBox(
  width: 15,
);
const w20 = SizedBox(
  width: 20,
);
const w30 = SizedBox(
  width: 30,
);
const h5 = SizedBox(
  height: 05,
);
const h10 = SizedBox(
  height: 10,
);
const h20 = SizedBox(
  height: 20,
);
const h30 = SizedBox(
  height: 30,
);

// Border Radiuses
BorderRadius br5 = BorderRadius.circular(05);
BorderRadius br8 = BorderRadius.circular(08);
BorderRadius br10 = BorderRadius.circular(10);
BorderRadius br12 = BorderRadius.circular(12);
BorderRadius br15 = BorderRadius.circular(15);
BorderRadius br20 = BorderRadius.circular(20);
BorderRadius br30 = BorderRadius.circular(30);

AppBar commonAppBar(
  BuildContext context, {
  dynamic widget,
  String? title,
  bool showBackBtn = false,
  bool showGearIcon = false,
  bool showBatteryLevel = true,
}) {
  return AppBar(
    backgroundColor: AppColors.white,
    elevation: 0,
    leading: showBackBtn
        ? IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back_ios_new_rounded))
        : null,
    title: Text(title!, style: const TextStyle(fontSize: 18)),
    actions: [
      if (showBatteryLevel) BatteryIndicator(batteryLevel: widget.batteryLevel),
      w5,
      if (showGearIcon)
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingPage(
                    device: widget.device, batteryLevel: widget.batteryLevel),
              ),
            );
          },
          child: CircleAvatar(
            child: CustomIconButton(
              size: 26.h,
              iconPath: AppImages.gearIcon,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingPage(
                        device: widget.device,
                        batteryLevel: widget.batteryLevel),
                  ),
                );
              },
            ),
          ),
        ),
      w10
    ],
  );
}

//Snackbar
void avmSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.greyLavender,
      content: Text(
        content,
        style: const TextStyle(
          fontFamily: "Montserrat",
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppColors.lightBg,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: br12),
      padding: const EdgeInsets.all(14),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(18),
    ),
  );
}
