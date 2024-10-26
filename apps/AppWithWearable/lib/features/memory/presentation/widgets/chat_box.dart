import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:friend_private/core/expandableText_util.dart';

class ChatBoxWidget extends StatelessWidget {
  const ChatBoxWidget({
    super.key,
    required this.speaker,
    required this.text,
  });

  final String speaker;
  final String text;

  @override
  Widget build(BuildContext context) {
    log('transcript tab- Speaker: $speaker, Text: $text');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(40, 255, 255, 255),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            // Format the speaker text like "Speaker 1:"
            "$speaker:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ExpandableTextUtil(
            text: text,
            style: const TextStyle(
              color: Color.fromARGB(255, 228, 228, 228),
            ),
          ),
        ],
      ),
    );
  }
}
