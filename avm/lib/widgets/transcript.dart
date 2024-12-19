import 'package:avm/backend/database/transcript_segment.dart';
import 'package:avm/features/memory/presentation/widgets/chat_box.dart';
import 'package:flutter/material.dart';

class TranscriptWidget extends StatefulWidget {
  final List<TranscriptSegment> segments;
  final bool horizontalMargin;
  final bool topMargin;
  final bool canDisplaySeconds;

  const TranscriptWidget({
    super.key,
    required this.segments,
    this.horizontalMargin = true,
    this.topMargin = true,
    this.canDisplaySeconds = true,
  });

  @override
  State<TranscriptWidget> createState() => _TranscriptWidgetState();
}

class _TranscriptWidgetState extends State<TranscriptWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // You can choose one of these background styles:

        // Option 1: Solid color
        //  color: CustomColors.greyLight, // Light grey background

        // Option 2: Gradient background
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [
        //     Colors.blue.shade50,
        //     Colors.white,
        //   ],
        // ),

        // Option 3: Subtle pattern with opacity
        color: Colors.blue.shade50.withValues(alpha: 0.1),

        // Add rounded corners if needed
        borderRadius: BorderRadius.circular(12),
      ),
      // Add padding around the entire list
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: widget.segments.length,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(height: 16.0),
        itemBuilder: (context, idx) {
          TranscriptSegment segment = widget.segments[idx];
          return ChatBoxWidget(segment: segment);
        },
      ),
    );
  }
}
