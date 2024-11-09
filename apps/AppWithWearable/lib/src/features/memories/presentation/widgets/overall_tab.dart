import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/src/core/common_widget/expandable_text.dart';
import 'package:friend_private/src/core/common_widget/list_tile.dart';
import 'package:friend_private/src/core/constant/constant.dart';

class OverallTab extends StatelessWidget {
  final Structured
      target; // Replace `Memory` with the actual data type you have

  const OverallTab({super.key, required this.target});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final events = target?.events ?? [];
    final actionItems = target?.actionItems ??
        []; // Replace `actionItems` with the correct field in `target`
    print(target);
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
            text: target.overview,
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
            title: Text('Events', style: textTheme.titleMedium),
          ),

          if (events.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'No events found',
                style: textTheme.bodyLarge?.copyWith(
                  color: CustomColors.grey,
                ),
              ),
            )
          else
            ...events.asMap().entries.map((entry) {
              int index = entry.key + 1;
              var event = entry.value;

              return CustomListTile(
                leading: Text(
                  '$index.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: CustomColors.grey,
                  ),
                ),
                title: Text(
                  event, // Replace this with the correct event property if needed
                  style: textTheme.bodyLarge?.copyWith(
                    color: CustomColors.grey,
                  ),
                ),
              );
            }),
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

          /// Action Items Section
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
          if (actionItems.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'No action items found',
                style: textTheme.bodyLarge?.copyWith(
                  color: CustomColors.grey,
                ),
              ),
            )
          else
            ...actionItems.map((actionItem) {
              return CustomListTile(
                minLeadingWidth: 0.w,
                onTap: () {
                  // Add event to save the action, if necessary
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
                  actionItem, // Replace with the correct action item property
                  style: textTheme.bodyLarge?.copyWith(
                    color: CustomColors.grey,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: CustomColors.greyLight,
                  ),
                ),
              );
            }).toList(),

          // CustomListTile(
          //   minLeadingWidth: 0.w,
          //   onTap: () {
          //     // Add event to save the action
          //   },
          //   leading: Container(
          //     width: 6.h,
          //     height: 6.w,
          //     decoration: const BoxDecoration(
          //       color: CustomColors.grey,
          //       shape: BoxShape.circle,
          //     ),
          //   ),
          //   title: Text(
          //     'The development team should continue working on '
          //     'resolving any outstanding issues identified in testing.',
          //     style: textTheme.bodyLarge?.copyWith(
          //       color: CustomColors.grey,
          //       decoration: TextDecoration.lineThrough,
          //       decorationColor: CustomColors.greyLight,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
