import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/src/core/common_widget/card.dart';
import 'package:friend_private/src/core/constant/custom_colors.dart';
import 'package:friend_private/src/core/constant/icon_image.dart';

class MemoryCard extends StatelessWidget {
  const MemoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CustomCard(
      borderRadius: 30.h + 12.h,
      padding:  EdgeInsets.all(12.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30.h),
            child: Image.asset(
              IconImage.imagePlaceholder,
              height: 100.h,
              width: 100.w,
              fit: BoxFit.fitHeight,
            ),
          ),
           SizedBox(width: 8.w),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Embracing the change and growth in Technology'
                'Embracing the change and growth in Technology',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w400),
              ),
               SizedBox(height: 12.h),
              Text(
                '21 Oct 2024 | 09:21 PM',
                style: textTheme.bodySmall?.copyWith(
                  color: CustomColors.greyLight,
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
