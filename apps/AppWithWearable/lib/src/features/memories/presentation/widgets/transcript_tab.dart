import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/src/core/common_widget/expandable_text.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:timelines/timelines.dart';

class TranscriptTab extends StatelessWidget {
  final MemoryBloc memoryBloc;
  final int memoryAtIndex;
  //final PageController pageController; // Added this parameter

  const TranscriptTab({
    super.key,
    required this.memoryBloc,
    required this.memoryAtIndex,
    //required this.pageController, // Added this parameter
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoryBloc, MemoryState>(
      bloc: memoryBloc,
      builder: (context, state) {
        final transcriptSegments =
            state.memories[memoryAtIndex].transcriptSegments;

        return Timeline.tileBuilder(
          physics: BouncingScrollPhysics(),
          theme: TimelineThemeData(
            nodePosition: 0.h,
            indicatorPosition: 0.04.h,
          ),
          padding: EdgeInsets.symmetric(vertical: 20.h),
          builder: TimelineTileBuilder.connected(
            contentsBuilder: (context, index) => _TranscriptContent(
              segment: transcriptSegments[index],
            ),
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
            itemCount: transcriptSegments.length,
          ),
        );
      },
    );
  }
}

class _TranscriptContent extends StatelessWidget {
  final TranscriptSegment segment;

  const _TranscriptContent({required this.segment});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 30.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Text(
            segment.timestamp ?? '00:00:30',
            style: textTheme.titleMedium?.copyWith(
              color: CustomColors.greyLight,
            ),
          ),
          ExpandableText(
            leadingText: 'Speaker ${segment.speaker}: ',
            text: segment.text,
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
