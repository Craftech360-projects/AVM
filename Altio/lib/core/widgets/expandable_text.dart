import 'package:altio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText({
    required this.text,
    super.key,
    this.style,
    this.padding,
    this.leadingText,
  });

  final String text;
  final String? leadingText;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;
  bool _isOverflowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkOverflow();
      }
    });
  }

  void _checkOverflow() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    );

    if (context.size != null) {
      textPainter.layout(maxWidth: context.size!.width);

      if (textPainter.didExceedMaxLines) {
        setState(() {
          _isOverflowing = true;
        });
      }
    }
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            child: _expanded
                ? SelectableText.rich(
                    TextSpan(
                      children: [
                        if (widget.leadingText != null)
                          TextSpan(
                            text: widget.leadingText,
                            style: theme.bodyMedium
                                ?.copyWith(color: AppColors.blue),
                          ),
                        TextSpan(
                          text: widget.text,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : Text.rich(
                    TextSpan(
                      children: [
                        if (widget.leadingText != null)
                          TextSpan(
                            text: widget.leadingText,
                            style: theme.bodyMedium
                                ?.copyWith(color: AppColors.blue),
                          ),
                        TextSpan(
                          text: widget.text,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          if (_isOverflowing)
            GestureDetector(
              onTap: _toggleExpanded,
              child: Text(
                _expanded ? 'See less..' : 'Read more..',
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
