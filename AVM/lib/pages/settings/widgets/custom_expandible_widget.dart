import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomExpansionTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Color? collapsedColor;
  final Color? expandedColor;
  final Color textColor;
  final Icon trailingIcon;
  final Icon leadingIcon;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.subtitle = '',
    this.collapsedColor,
    this.expandedColor,
    this.textColor = AppColors.greyDark,
    this.trailingIcon = const Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: AppColors.grey,
    ),
    this.leadingIcon = const Icon(
      Icons.category,
      color: AppColors.grey,
      size: 24,
    ),
  });

  @override
  CustomExpansionTileState createState() => CustomExpansionTileState();
}

class CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late Color collapsedColor;
  late Color expandedColor;
  late Icon trailingIcon;
  late Icon leadingIcon;

  @override
  void initState() {
    super.initState();
    collapsedColor = AppColors.blueGreyDark.withValues(alpha: 0.6);
    expandedColor = AppColors.commonPink;
    trailingIcon = const Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: AppColors.grey,
    );
    leadingIcon = const Icon(
      Icons.category,
      color: AppColors.grey,
      size: 24,
    );
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: br8,
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
