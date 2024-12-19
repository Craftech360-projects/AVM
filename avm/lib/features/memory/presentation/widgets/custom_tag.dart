import 'package:flutter/material.dart';

class CustomTag extends StatelessWidget {
  const CustomTag({
    super.key,
    required this.tagName,
    this.backgroundColor = Colors.transparent,
    this.side = const BorderSide(
      color: Colors.grey,
      width: 0.5,
    ),
  });
  final String tagName;
  final Color backgroundColor;
  final BorderSide side;

  @override
  Widget build(BuildContext context) {
    return Chip(
      elevation: 0,
      visualDensity: const VisualDensity(vertical: -4),
      labelPadding: EdgeInsets.zero,
      backgroundColor: backgroundColor,
      label: Text(
        tagName,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: side
      ),
    );
  }
}
