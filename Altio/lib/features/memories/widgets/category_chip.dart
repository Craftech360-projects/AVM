import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.tagName,
  });
  final String tagName;
  @override
  Widget build(BuildContext context) {
    return Chip(
      elevation: 1,
      visualDensity: VisualDensity(vertical: -3.h),
      labelPadding: EdgeInsets.zero,
      backgroundColor: AppColors.purpleDark,
      label: Text(
        tagName,
        style: TextStyle(color: AppColors.white),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: br5, side: BorderSide(color: Colors.transparent)),
    );
  }
}
