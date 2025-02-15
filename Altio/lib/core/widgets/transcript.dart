import 'package:altio/backend/database/transcript_segment.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
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
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: const BoxDecoration(color: AppColors.purpleDark),
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
      ),
    );
  }
}
