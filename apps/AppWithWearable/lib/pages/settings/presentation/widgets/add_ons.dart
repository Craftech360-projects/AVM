import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/src/core/common_widget/list_tile.dart';

class AddOns extends StatelessWidget {
  const AddOns({
    super.key,
    required this.title,
    this.icon,
    required this.onPressed,
  });
  final String title;
  final Widget? icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CustomListTile(
      title: Text(
        title,
        style: textTheme.bodyLarge,
      ),
      trailing: icon ??
          Icon(
            Icons.arrow_forward_ios,
            size: 22.h,
          ),
      onTap: onPressed,
    );
  }
}
