import 'package:capsoul/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final Widget onSubmit;
  final Widget onCancel;

  const CustomDialog({
    super.key,
    this.title = '',
    required this.content,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.h),
      ),
      title: Text(title),
      content: SingleChildScrollView(
        child: Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      actions: [
        onCancel,
        onSubmit,
      ],
    );
  }
}
