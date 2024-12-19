import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';

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
      elevation: 1,
      visualDensity: VisualDensity(vertical: -3.h),
      labelPadding: EdgeInsets.zero,
      backgroundColor: AppColors.commonPink,
      label: Text(
        tagName,
        style: textTheme.bodyMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: br5,
        side: const BorderSide(
          color: Colors.transparent,
          width: 0,
        ),
      ),
    );
  }
}
