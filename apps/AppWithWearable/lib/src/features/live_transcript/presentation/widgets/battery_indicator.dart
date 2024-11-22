import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:friend_private/src/core/constant/constant.dart';

class BatteryIndicator extends StatelessWidget {
  const BatteryIndicator({
    super.key,
    this.batteryLevel,
  });
  final int? batteryLevel;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.w),
        Center(
          child: Container(
            width: 25.h, // Adjust the size to your preference
            height: 25.h, // Same as width to make it circular
            decoration: BoxDecoration(
              color: CustomColors.greyLavender, // Background color
              shape: BoxShape.circle, // Makes the container circular
            ),
            child: SvgPicture.asset(
              IconImage.batteryIndicator,
              height: 10.h,
              fit: BoxFit
                  .scaleDown, // Ensure the icon fits nicely within the circle
            ),
          ),
        ),
        SizedBox(height: 8.h), // Add spacing between elements
        if (batteryLevel! > 0) ...[
          SizedBox(height: 8.h), // Add spacing only if text is shown
          Text(
            '$batteryLevel%',
            style: textTheme.bodySmall?.copyWith(fontSize: 12.h),
          ),
        ],
      ],
    );
  }
}
