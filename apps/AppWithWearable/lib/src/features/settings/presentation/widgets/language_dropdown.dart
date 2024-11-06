import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/src/core/constant/constant.dart';

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
      padding:  EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: CustomColors.greyLavender,
        borderRadius: BorderRadius.circular(20.h),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLanguage,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          items: languages.map((language) {
            return DropdownMenuItem<String>(
              value: language["name"],
              enabled: language["enabled"],
              child: Text(
                language["name"],
                style: TextStyle(
                  color: language["enabled"]
                      ? CustomColors.blackPrimary
                      : CustomColors.greyMedium2,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null && newValue == "English (en)") {
              setState(() {
                selectedLanguage = newValue;
              });
            }
          },
        ),
      ),
    );
  }
}
