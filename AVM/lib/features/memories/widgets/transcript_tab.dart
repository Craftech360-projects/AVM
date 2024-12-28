import 'package:avm/backend/database/transcript_segment.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/features/memory/bloc/memory_bloc.dart';
import 'package:avm/src/common_widget/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timelines_plus/timelines_plus.dart';

class TranscriptTab extends StatelessWidget {
  final MemoryBloc memoryBloc;
  final int memoryAtIndex;

  const TranscriptTab({
    super.key,
    required this.memoryBloc,
    required this.memoryAtIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoryBloc, MemoryState>(
      bloc: memoryBloc,
      builder: (context, state) {
        final transcriptSegments =
            state.memories[memoryAtIndex].transcriptSegments;
        final started = state.memories[memoryAtIndex].startedAt ??
            DateTime.now(); // Use startedAt or current time if null
        print("started: $started");

        // Calculate dummy timeline times
        final segmentDuration =
            Duration(seconds: 7); // Assume 5 seconds for each segment
        final dummyTimes = List<DateTime>.generate(
          transcriptSegments.length,
          (index) => started.subtract(
              segmentDuration * (transcriptSegments.length - 1 - index)),
        );

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
              time: dummyTimes[index], // Pass dummy time
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
  final DateTime time; // Add time parameter

  const _TranscriptContent({
    required this.segment,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hour =
        time.hour % 12 == 0 ? 12 : time.hour % 12; // Handle 12-hour format
    final period = time.hour >= 12 ? 'PM' : 'AM'; // Determine AM or PM
    final timeString =
        "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')} $period";

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              timeString, // Use the formatted 12-hour time
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
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
