import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/core/assets/app_images.dart';
import 'package:friend_private/src/common_widget/icon_button.dart';

class BatteryIndicator extends StatelessWidget {
  const BatteryIndicator({
    super.key,
    required int batteryLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "66%",
          style: TextStyle(fontSize: 14),
        ),
        CustomIconButton(
          size: 22.h,
          iconPath: AppImages.batteryIcon,
          onPressed: () {},
        ),
      ],
    );
  }
}
