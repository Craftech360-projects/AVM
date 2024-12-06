import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:friend_private/core_updated/assets/app_vectors.dart';

class BatteryIndicator extends StatelessWidget {
  const BatteryIndicator({
    super.key,
    required int batteryLevel,
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
            AppVectors.batteryIndicator,
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
