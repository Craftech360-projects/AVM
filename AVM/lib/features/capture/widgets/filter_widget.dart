import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FilterOptionWidget extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterOptionWidget({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.purpleDark.withValues(alpha: 0.8)
              : AppColors.white,
          border: Border.all(color: AppColors.black),
          borderRadius: br12,
        ),
        child: Text(
          title,
          style:
              TextStyle(color: isSelected ? AppColors.white : AppColors.black),
        ),
      ),
      onTap: onTap,
    );
  }
}
