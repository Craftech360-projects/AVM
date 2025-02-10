import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  String selectedLanguage = "English (en)";

  final List<Map<String, dynamic>> languages = [
    {"name": "English (en)", "enabled": true},
    {"name": "Hindi (hi)", "enabled": false},
    {"name": "Bengali (bn)", "enabled": false},
    {"name": "Telugu (te)", "enabled": false},
    {"name": "Marathi (mr)", "enabled": false},
    {"name": "Tamil (ta)", "enabled": false},
    {"name": "Gujarati (gu)", "enabled": false},
    {"name": "Urdu (ur)", "enabled": false},
    {"name": "Kannada (kn)", "enabled": false},
    {"name": "Malayalam (ml)", "enabled": false},
    {"name": "Odia (or)", "enabled": false},
    {"name": "Punjabi (pa)", "enabled": false},
    {"name": "Assamese (as)", "enabled": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.greyLavender,
        borderRadius: br8,
      ),
      child: DropdownButtonHideUnderline(
        // This removes the underline
        child: DropdownButtonFormField<String>(
          value: selectedLanguage,
          items: languages.map((e) {
            return DropdownMenuItem<String>(
              value: e['name'],
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  style: Theme.of(context).textTheme.bodyMedium,
                  e['name'],
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              selectedLanguage = value ?? selectedLanguage;
            });
          },
          isDense: true,
          isExpanded: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
          ),
          dropdownColor: AppColors.white,
        ),
      ),
    );
  }
}
