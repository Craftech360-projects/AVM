import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/core/expandableText_util.dart';

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
          color: isCurrentUser
              ? const Color.fromARGB(66, 0, 0, 0)
              : const Color.fromARGB(40, 255, 255, 255),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isCurrentUser ? const Radius.circular(12) : Radius.zero,
            bottomRight: isCurrentUser ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isCurrentUser
                  ? '$yourName (You)'
                  : 'Speaker: ${segment.speaker}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ExpandableTextUtil(
              text: segment.text,
              style: const TextStyle(
                color: Color.fromARGB(255, 228, 228, 228),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// class ChatBoxWidget extends StatelessWidget {
//   const ChatBoxWidget({super.key, required this.chatUser});
//   final ChatUser chatUser;

//   @override
//   Widget build(BuildContext context) {
//     final isCurrentUser = chatUser.id == '4';

//     return Align(
//       alignment: isCurrentUser ? Alignment.centerLeft : Alignment.centerRight,
//       child: Container(
//         margin: isCurrentUser
//             ? const EdgeInsets.only(top: 6, bottom: 6, right: 80, left: 8)
//             : const EdgeInsets.only(top: 6, bottom: 6, right: 8, left: 80),
//         padding: const EdgeInsets.only(top: 10, bottom: 10, right: 8, left: 12),
         
//         decoration: BoxDecoration(
//           color: isCurrentUser
//               ? const Color.fromARGB(40, 255, 255, 255)
//               : const Color.fromARGB(66, 0, 0, 0),
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(12),
//             topRight: const Radius.circular(12),
//             bottomLeft: isCurrentUser ? Radius.zero : const Radius.circular(12),
//             bottomRight:
//                 isCurrentUser ? const Radius.circular(12) : Radius.zero,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment:
//               isCurrentUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               isCurrentUser ? 'You' : chatUser.name,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 12),
//             ExpandableTextUtil(
//               text: chatUser.message,
//               style: const TextStyle(
//                 color: Color.fromARGB(255, 228, 228, 228),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
