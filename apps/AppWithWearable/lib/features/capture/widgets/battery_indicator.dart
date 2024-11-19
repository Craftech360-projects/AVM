import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:friend_private/src/core/constant/constant.dart';

class BatteryIndicator extends StatelessWidget {
  const BatteryIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SvgPicture.asset(
            height: 12.h,
            IconImage.batteryIndicator,
          ),
        ),
        SizedBox(width: 4.h),
        Text(
          ' 66%',
          style: textTheme.bodySmall?.copyWith(fontSize: 12.h),
        )
      ],
    );
  }
}
