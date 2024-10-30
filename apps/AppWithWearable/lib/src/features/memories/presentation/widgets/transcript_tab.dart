import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/src/core/common_widget/expandable_text.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:timelines/timelines.dart';

class TranscriptTab extends StatelessWidget {
  const TranscriptTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Timeline.tileBuilder(
      physics: const BouncingScrollPhysics(),
      theme: TimelineThemeData(
        nodePosition: 0.h,
        indicatorPosition: 0.04.h,
      ),
      padding: EdgeInsets.symmetric(vertical: 20.h),
      builder: TimelineTileBuilder.connected(
        contentsBuilder: (_, __) => _TranscriptContent(),
        connectorBuilder: (_, index, __) {
          return SolidLineConnector(
            color: CustomColors.greyMedium2,
            thickness: 1.5.w,
          );
        },
        indicatorBuilder: (_, index) {
          return OutlinedDotIndicator(
            size: 14.h,
            color: CustomColors.greyLight,
            backgroundColor: CustomColors.white,
          );
        },
        itemCount: 12,
      ),
    );
  }
}

class _TranscriptContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 30.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '00:00:30',
            style: textTheme.titleMedium?.copyWith(
              color: CustomColors.greyLight,
            ),
          ),
          ExpandableText(
            leadingText: 'Speaker 1: ',
            text:
                "We have to find the Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                "Phasellus convallis neque nec sagittis convallis. Etiam non consequat lectus."
                "We have to find the Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                "Phasellus convallis neque nec sagittis convallis. Etiam non consequat lectus."
                "We have to find the Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                "Phasellus convallis neque nec sagittis convallis. Etiam non consequat lectus.",
            style: textTheme.bodyMedium?.copyWith(
              wordSpacing: 0,
              letterSpacing: 0.1,
            ),
          )
        ],
      ),
    );
  }
}
