import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? trailing;
  final EdgeInsetsGeometry contentPadding;
  final VisualDensity? visualDensity;
  final VoidCallback? onTap;

  final double? minLeadingWidth;

  const CustomListTile({
    super.key,
    this.leading,
    required this.title,
    this.trailing,
    this.contentPadding = EdgeInsets.zero,
    this.visualDensity = const VisualDensity(vertical: -4),
    this.onTap,
    this.minLeadingWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: contentPadding,
      visualDensity: visualDensity,
      minLeadingWidth: minLeadingWidth,
      leading: leading,
      title: title,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
