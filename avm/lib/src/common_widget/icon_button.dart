import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.size,
    required this.iconPath,
    required this.onPressed,
  });
  final double size;
  final String iconPath;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Image.asset(
        iconPath,
        height: size,
        width: size,
        // colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
    );
  }
}
