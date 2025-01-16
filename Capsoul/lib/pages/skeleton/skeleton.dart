import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Skeleton extends StatelessWidget {
  const Skeleton({super.key, this.height, this.width});

  final double? height, width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      // padding: const EdgeInsets.all(16.0 / 2),
      decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.04), borderRadius: br15),
    );
  }
}

class CircleSkeleton extends StatelessWidget {
  const CircleSkeleton({super.key, this.size = 24});

  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.04),
        shape: BoxShape.circle,
      ),
    );
  }
}
