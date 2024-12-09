import 'package:flutter/material.dart';
import 'package:friend_private/core/constants/constants.dart';
import 'package:friend_private/core/theme/app_colors.dart';

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
          color: AppColors.black.withOpacity(0.04),
          borderRadius: br15),
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
        color: Theme.of(context).primaryColor.withOpacity(0.04),
        shape: BoxShape.circle,
      ),
    );
  }
}
