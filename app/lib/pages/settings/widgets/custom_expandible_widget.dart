import 'package:flutter/material.dart';
import 'package:friend_private/core/theme/app_colors.dart';

class CustomExpansionTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Color collapsedColor;
  final Color expandedColor;
  final Color textColor;
  final BorderRadiusGeometry borderRadius;
  // final EdgeInsetsGeometry tilePadding;
  // final EdgeInsetsGeometry childrenPadding;
  final Icon trailingIcon;
  final Icon leadingIcon;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.subtitle = '',
    this.collapsedColor = const Color(0x22FFFFFF),
    this.expandedColor = AppColors.greyLavender,
    this.textColor = const Color.fromARGB(255, 50, 50, 50),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    // this.tilePadding = const EdgeInsets.symmetric(horizontal: 16),
    // this.childrenPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailingIcon = const Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: Colors.grey,
    ),
    this.leadingIcon = const Icon(
      Icons.category,
      color: Colors.grey,
      size: 24,
    ),
  });

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _isExpanded ? widget.expandedColor : widget.collapsedColor,
        child: Column(
          children: [
            ListTile(
              title: Text(
                widget.title,
                style: TextStyle(
                  color: widget.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: (widget.subtitle != null && widget.subtitle!.isNotEmpty)
                  ? Text(
                      widget.subtitle ?? '',
                      style: TextStyle(
                        color: widget.textColor.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    )
                  : null,
              trailing: RotationTransition(
                turns: AlwaysStoppedAnimation(_isExpanded ? 90 / 360 : 0),
                child: widget.trailingIcon,
              ),
              onTap: _handleTap,
            ),
            if (_isExpanded)
              Column(
                children: widget.children,
              ),
          ],
        ),
      ),
    );
  }
}
