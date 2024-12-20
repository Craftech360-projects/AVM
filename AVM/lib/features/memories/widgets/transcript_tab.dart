import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avm/backend/database/transcript_segment.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/features/memory/bloc/memory_bloc.dart';
import 'package:avm/src/common_widget/expandable_text.dart';
import 'package:timelines_plus/timelines_plus.dart';

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
          physics: const BouncingScrollPhysics(),
          theme: TimelineThemeData(
            nodePosition: 0.0.h,
            indicatorPosition: 0.05.h,
          ),
          padding: EdgeInsets.symmetric(vertical: 20.h),
          builder: TimelineTileBuilder.connected(
            contentsBuilder: (context, index) => _TranscriptContent(
              segment: transcriptSegments[index],
            ),
            connectorBuilder: (_, index, __) {
              return SolidLineConnector(
                color: AppColors.black,
                thickness: 1.w,
              );
            },
            indicatorBuilder: (_, index) {
              return OutlinedDotIndicator(
                size: 14.h,
                color: AppColors.greyLight,
                backgroundColor: AppColors.white,
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
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 05),
            child: Text(
              segment.timestamp ?? '00:00:30',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 05),
            child: ExpandableText(
              leadingText: 'Speaker ${segment.speaker} : ',
              text: segment.text,
              style: textTheme.bodyMedium?.copyWith(
                wordSpacing: 0,
                letterSpacing: 0.1,
              ),
            ),
          )
        ],
      ),
    );
  }
}
