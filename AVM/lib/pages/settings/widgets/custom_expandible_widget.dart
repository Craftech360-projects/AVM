import 'package:avm/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomExpansionTile extends StatefulWidget {
  final Icon trailingIcon;
  final Icon leadingIcon;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Color expandedColor;
  final BorderRadiusGeometry borderRadius;

  const CustomExpansionTile({
    super.key,
    this.trailingIcon = const Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: AppColors.black,
    ),
    this.leadingIcon = const Icon(
      Icons.category,
      color: AppColors.black,
      size: 24,
    ),
    required this.title,
    this.subtitle,
    required this.children,
    this.expandedColor = AppColors.greyLavender,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  CustomExpansionTileState createState() => CustomExpansionTileState();
}

class CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: _isExpanded ? widget.expandedColor : AppColors.commonPink,
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
                title: Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle:
                    (widget.subtitle != null && widget.subtitle!.isNotEmpty)
                        ? Text(
                            widget.subtitle ?? '',
                            style: TextStyle(
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
      ),
    );
  }
}
