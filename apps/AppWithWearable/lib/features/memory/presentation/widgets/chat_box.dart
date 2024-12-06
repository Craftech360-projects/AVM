import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/core_updated/theme/app_colors.dart';
import 'package:friend_private/core_updated/widgets/expandableText_util.dart';

class ChatBoxWidget extends StatelessWidget {
  const ChatBoxWidget({super.key, required this.segment});
  final TranscriptSegment segment;

  @override
  Widget build(BuildContext context) {
    log('transcript tab- $segment');
    // final isCurrentUser = chatUser.id == '4';
    final isCurrentUser = segment.speaker == '0';
    final yourName = SharedPreferencesUtil().givenName;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: isCurrentUser
            ? const EdgeInsets.only(top: 6, bottom: 6, right: 8, left: 80)
            : const EdgeInsets.only(top: 6, bottom: 6, right: 80, left: 8),
        padding: const EdgeInsets.only(top: 10, bottom: 10, right: 12, left: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(186, 255, 255, 255),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isCurrentUser ? const Radius.circular(12) : Radius.zero,
            bottomRight:
                isCurrentUser ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isCurrentUser ? '$yourName (You)' : 'Speaker: ${segment.speaker}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.blackPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ExpandableTextUtil(
              text: segment.text,
              style: const TextStyle(
                color: AppColors.blackPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
