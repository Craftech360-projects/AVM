import 'package:flutter/material.dart';

class CustomTag extends StatelessWidget {
  const CustomTag({super.key, required this.tagName});
  final String tagName;

  @override
  Widget build(BuildContext context) {
    return Chip(
      elevation: 0,
      visualDensity: const VisualDensity(vertical: -4),
      labelPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent, 
      label: Text(
        tagName,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6), 
        side: const BorderSide(
          color: Colors.grey,
          width: 0.5, 
        ),
      ),
    );
  }
}
