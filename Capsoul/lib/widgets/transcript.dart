import 'package:capsoul/backend/database/transcript_segment.dart';
import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:collection/collection.dart';
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
  bool _expanded = false;

  @override
  void didUpdateWidget(covariant TranscriptWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!const DeepCollectionEquality()
        .equals(widget.segments, oldWidget.segments)) {
      debugPrint(
          "TranscriptWidget segments updated from ${oldWidget.segments.length} to ${widget.segments.length}");
      setState(() {});
    }
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "Rebuilding TranscriptWidget: ${widget.segments.length} segments in TW");
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.purpleDark),
        borderRadius: br8,
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.segments.length,
        separatorBuilder: (_, __) => h4,
        itemBuilder: (context, idx) {
          final segment = widget.segments[idx];
          return Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.commonPink,
                borderRadius: br8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Speaker: ${segment.speaker}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  h4,
                  AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                    child: Text(
                      segment.text,
                      overflow: _expanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleExpanded,
                    child: Text(
                      _expanded ? 'See less' : 'Read more...',
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
