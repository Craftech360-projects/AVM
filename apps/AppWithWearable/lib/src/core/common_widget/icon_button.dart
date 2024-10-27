import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friend_private/src/core/constant/custom_colors.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.size,
    required this.iconPath,
    required this.onPressed,
    this.iconColor = CustomColors.blackPrimary,
  });
  final double size;
  final String iconPath;
  final Color iconColor;
    final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SvgPicture.asset(
        iconPath,
        height: size,
        width: size,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
    );
  }
}
