import 'package:capsaul/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    this.backgroundColor = AppColors.black,
    required this.child,
    this.icon,
  });
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Widget child;
  final Widget? icon;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon,
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.black,
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      label: child,
    );
  }
}
