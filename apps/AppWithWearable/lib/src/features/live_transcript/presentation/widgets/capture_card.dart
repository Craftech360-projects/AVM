import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/constant/constant.dart';

class CaptureCard extends StatelessWidget {
  const CaptureCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CustomCard(
      borderRadius: 40.h + 12.h,
      padding: EdgeInsets.all(12.h),
      child: Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40.h),
              child: Image.asset(
                IconImage.avmdevice,
                height: 150.h,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 80.h,
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    '👋Hi! Joe,\nChange is inevitable. '
                    'Always strive for the next big thing.!',
                    textStyle: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w400),
                  ),
                ],
                isRepeatingAnimation: false,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Check AVM Device",
              style:
                  textTheme.bodySmall?.copyWith(color: CustomColors.greyLight),
            ),
            Row(
              children: [
                Container(
                  width: 8.h,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: CustomColors.yellowAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.h),
                Text(
                  "Disconnected",
                  style: textTheme.bodySmall
                      ?.copyWith(color: CustomColors.greyLight, fontSize: 10.h),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
