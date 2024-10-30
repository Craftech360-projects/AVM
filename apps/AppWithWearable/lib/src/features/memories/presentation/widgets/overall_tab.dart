import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friend_private/src/core/common_widget/expandable_text.dart';
import 'package:friend_private/src/core/common_widget/list_tile.dart';
import 'package:friend_private/src/core/constant/constant.dart';

class OverallTab extends StatelessWidget {
  const OverallTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// AI Summary
          CustomListTile(
            leading: SvgPicture.asset(
              IconImage.summary,
              height: 18.h,
              width: 18.w,
            ),
            title: Text(
              'AI Summary',
              style: textTheme.titleMedium,
            ),
          ),
           ExpandableText(
            text: 'The project partners discussed progress '
                'and address any concerns on a project that is nearing the point.'
                'The project partners discussed progress and address'
                'any concerns on a project that is nearing the point.'
                'The project partners discussed progress '
                'and address any concerns on a project that is nearing the point.'
                'The project partners discussed progress and address'
                'any concerns on a project that is nearing the point.',
                  style: textTheme.bodyLarge?.copyWith(
                color: CustomColors.grey,
              ),
          ),
          SizedBox(height: 12.h),

          /// Chapters
          CustomListTile(
            leading: SvgPicture.asset(
              IconImage.chapter,
              height: 18.h,
              width: 18.w,
            ),
            title: Text('Chapters', style: textTheme.titleMedium),
          ),
          CustomListTile(
            leading: Text(
              '1.',
              style: textTheme.bodyLarge?.copyWith(
                color: CustomColors.grey,
              ),
            ),
            title: Text(
              'Development Team Update',
              style: textTheme.bodyLarge?.copyWith(
                color: CustomColors.grey,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          /// Action Items
          CustomListTile(
            leading: SvgPicture.asset(
              IconImage.action,
              height: 18.h,
              width: 18.w,
            ),
            title: Text(
              'Action Items',
              style: textTheme.titleMedium,
            ),
          ),
          CustomListTile(
            minLeadingWidth: 0.w,
            onTap: () {
              // Add event to save the action
            },
            leading: Container(
              width: 6.h,
              height: 6.w,
              decoration: const BoxDecoration(
                color: CustomColors.grey,
                shape: BoxShape.circle,
              ),
            ),
            title: Text(
              'The development team should continue working on '
              'resolving any outstanding issues identified in testing.',
              style: textTheme.bodyLarge?.copyWith(
                color: CustomColors.grey,
                decoration: TextDecoration.lineThrough,
                 decorationColor: CustomColors.greyLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
