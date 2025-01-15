import 'package:capsoul/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ExpandableTextUtil extends StatefulWidget {
  const ExpandableTextUtil({
    required this.text,
    super.key,
    this.style,
    this.padding,
  });

  final String text;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;

  @override
  State<ExpandableTextUtil> createState() => _ExpandableTextUtilState();
}

class _ExpandableTextUtilState extends State<ExpandableTextUtil> {
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
            curve: Curves.ease,
            child: Text(
              widget.text,
              maxLines: _expanded ? null : 3,
              style: widget.style ?? theme.bodyLarge,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
          if (_isOverflowing)
            GestureDetector(
              onTap: _toggleExpanded,
              child: Text(
                _expanded ? 'See less' : 'Read more...',
                style: theme.bodyLarge?.copyWith(color: AppColors.white),
              ),
            ),
        ],
      ),
    );
  }
}
