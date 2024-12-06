import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/core_updated/theme/app_colors.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';

class MemoryShimmer extends StatelessWidget {
  const MemoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderRadius: 30.h + 12.h,
      padding: EdgeInsets.all(12.h),
      child: Row(
        children: [
          CustomShimmer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.h),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.greyDark,
                ),
                height: 100.h,
                width: 100.w,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomShimmer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.greyDark,
                  ),
                  height: 14.h,
                  width: 200.w,
                ),
              ),
              SizedBox(height: 25.h),
              CustomShimmer(
                child: Container(
                  height: 14.h,
                  width: 130.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.greyDark,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
