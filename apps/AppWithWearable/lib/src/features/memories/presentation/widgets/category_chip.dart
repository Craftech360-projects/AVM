import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/src/core/constant/constant.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.tagName,
  });
  final String tagName;
  @override
  Widget build(BuildContext context) {
       final textTheme = Theme.of(context).textTheme;
    return Chip(
      elevation: 2,
      visualDensity:  VisualDensity(vertical: -3.h),
      labelPadding: EdgeInsets.zero,
      backgroundColor: CustomColors.greyLavender,
      label: Text(
        tagName,
        style: textTheme.bodyMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.h),
        side: const BorderSide(
          color: Colors.transparent,
          width: 0,
        ),
      ),
    );
  }
}
