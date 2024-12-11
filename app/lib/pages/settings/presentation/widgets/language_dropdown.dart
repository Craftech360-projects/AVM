// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:friend_private/core/theme/app_colors.dart';

// class LanguageDropdown extends StatefulWidget {
//   const LanguageDropdown({super.key});

//   @override
//   State<LanguageDropdown> createState() => _LanguageDropdownState();
// }

// class _LanguageDropdownState extends State<LanguageDropdown> {
//   String selectedLanguage = "English (en)";

//   final List<Map<String, dynamic>> languages = [
//     {"name": "English (en)", "enabled": true},
//     {"name": "Hindi (hi)", "enabled": false},
//     {"name": "Bengali (bn)", "enabled": false},
//     {"name": "Telugu (te)", "enabled": false},
//     {"name": "Marathi (mr)", "enabled": false},
//     {"name": "Tamil (ta)", "enabled": false},
//     {"name": "Gujarati (gu)", "enabled": false},
//     {"name": "Urdu (ur)", "enabled": false},
//     {"name": "Kannada (kn)", "enabled": false},
//     {"name": "Malayalam (ml)", "enabled": false},
//     {"name": "Odia (or)", "enabled": false},
//     {"name": "Punjabi (pa)", "enabled": false},
//     {"name": "Assamese (as)", "enabled": false},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       decoration: BoxDecoration(
//         color: AppColors.greyLavender,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: DropdownButtonHideUnderline(
//         // This removes the underline
//         child: DropdownButtonFormField<String>(
//           value: selectedLanguage,
//           items: languages.map((e) {
//             return DropdownMenuItem<String>(
//               value: e['name'],
//               child: SizedBox(
//                 width: double.infinity,
//                 child: Text(
//                   e['name'],
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             );
//           }).toList(),
//           onChanged: (String? value) {
//             setState(() {
//               selectedLanguage = value ?? selectedLanguage;
//             });
//           },
//           isDense: true,
//           isExpanded: true,
//           decoration: const InputDecoration(
//             contentPadding: EdgeInsets.zero,
//             border: InputBorder.none,
//           ),
//           dropdownColor: AppColors.white,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/features/capture/logic/websocket_mixin.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown>
    with WebSocketMixin {
  String selectedLanguage = "English (en)";

  final List<Map<String, dynamic>> languages = [
    {"name": "English (en)", "code": "en", "enabled": true},
    {"name": "Hindi (hi)", "code": "hi", "enabled": false},
    {"name": "Bengali (bn)", "code": "bn", "enabled": false},
    {"name": "Telugu (te)", "code": "te", "enabled": false},
    {"name": "Marathi (mr)", "code": "mr", "enabled": false},
    {"name": "Tamil (ta)", "code": "ta", "enabled": false},
    {"name": "Gujarati (gu)", "code": "gu", "enabled": false},
    {"name": "Urdu (ur)", "code": "ur", "enabled": false},
    {"name": "Kannada (kn)", "code": "kn", "enabled": false},
    {"name": "Malayalam (ml)", "code": "ml", "enabled": false},
    {"name": "Odia (or)", "code": "or", "enabled": false},
    {"name": "Punjabi (pa)", "code": "pa", "enabled": false},
    {"name": "Assamese (as)", "code": "as", "enabled": false},
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    String savedLanguageCode = SharedPreferencesUtil().recordingsLanguage;
    Map<String, dynamic>? savedLanguage = languages.firstWhere(
      (lang) => lang['code'] == savedLanguageCode,
      orElse: () => {"name": "English (en)", "code": "en"},
    );
    setState(() {
      selectedLanguage = savedLanguage['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.greyLavender,
        borderRadius: BorderRadius.circular(12),
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
                  e['name'],
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? value) async {
            if (value != null) {
              setState(() {
                selectedLanguage = value;
              });

              // Save the selected language code to SharedPreferences
              final selectedCode = languages.firstWhere(
                (lang) => lang['name'] == value,
                orElse: () => {"code": "en"},
              )['code'] as String;
              await closeWebSocket();
              SharedPreferencesUtil().recordingsLanguage = selectedCode;

              await initWebSocket(
                onConnectionClosed: (int? closeCode, String? closeReason) {
                  setState(() {});
                },
                onConnectionSuccess: () {
                  setState(() {});
                },
                onConnectionError: (p1) {},
                onConnectionFailed: (p1) {},
                onMessageReceived: (List<TranscriptSegment> p1) {},
              );
            }
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
