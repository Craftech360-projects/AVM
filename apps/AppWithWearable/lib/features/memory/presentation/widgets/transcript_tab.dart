// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
// import 'package:friend_private/features/memory/presentation/widgets/chat_box.dart';

// class TranscriptTab extends StatefulWidget {
//   const TranscriptTab({
//     super.key,
//     required this.memoryAtIndex,
//     required this.memoryBloc,
//     required this.pageController,
//   });

//   final MemoryBloc memoryBloc;
//   final int memoryAtIndex;
//   final PageController pageController;

//   @override
//   State<TranscriptTab> createState() => _TranscriptTabState();
// }

// class _TranscriptTabState extends State<TranscriptTab> {
//   // late PageController _pageController;
//   @override
//   void initState() {
//     super.initState();

//     // _pageController = PageController(initialPage: widget.memoryAtIndex);
//     // widget.pageController.addListener(_onPageChanged);
//   }

//   // void _onPageChanged() {
//   //   final currentPage = widget.pageController.page?.round();
//   //   if (currentPage != null) {
//   //     widget.memoryBloc.add(MemoryIndexChanged(memoryIndex: currentPage));
//   //   }
//   // }

//   // @override
//   // void dispose() {
//   //   widget.pageController.removeListener(_onPageChanged);
//   //   super.dispose();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<MemoryBloc, MemoryState>(
//       bloc: widget.memoryBloc,
//       builder: (context, state) {
//         log('memory at transcript tab- ${state.memories[widget.memoryAtIndex].transcript}');

//         final transcriptSegments =
//             state.memories[widget.memoryAtIndex].transcriptSegments;

//         return ListView.builder(
//           itemCount: transcriptSegments.length,
//           itemBuilder: (context, index) {
//             final segment = transcriptSegments[index];
//             return ChatBoxWidget(segment: segment);
//           },
//         );
//       },
//     );
//   }
// }

//new

// transcript_tab.dart
// transcript_tab.dart
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/features/memory/presentation/widgets/chat_box.dart';

class TranscriptTab extends StatefulWidget {
  const TranscriptTab({
    super.key,
    required this.memoryAtIndex,
    required this.memoryBloc,
    required this.pageController,
  });

  final MemoryBloc memoryBloc;
  final int memoryAtIndex;
  final PageController pageController;

  @override
  State<TranscriptTab> createState() => _TranscriptTabState();
}

class _TranscriptTabState extends State<TranscriptTab> {
  List<Map<String, String>> parseTranscript(String transcriptStr) {
    try {
      // Remove the leading and trailing brackets
      String cleaned = transcriptStr.trim();
      if (cleaned.startsWith('[')) {
        cleaned = cleaned.substring(1);
      }
      if (cleaned.endsWith(']')) {
        cleaned = cleaned.substring(0, cleaned.length - 1);
      }

      // Split into individual message objects
      List<String> messages = cleaned.split('}, {');

      // Clean up and parse each message
      return messages.map((msg) {
        // Clean up remaining brackets
        msg = msg.replaceAll('{', '').replaceAll('}', '');

        // Parse the message into a map
        Map<String, String> messageMap = {};
        List<String> parts = msg.split(', ');

        for (String part in parts) {
          List<String> keyValue = part.split(': ');
          if (keyValue.length == 2) {
            String key = keyValue[0].trim();
            String value = keyValue[1].trim();
            messageMap[key] = value;
          }
        }

        return messageMap;
      }).toList();
    } catch (e) {
      log('Error parsing transcript: $e');
      return [
        {'speaker': 'Error', 'text': 'Failed to parse transcript'}
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoryBloc, MemoryState>(
      bloc: widget.memoryBloc,
      builder: (context, state) {
        final transcriptStr = state.memories[widget.memoryAtIndex].transcript;
        log('memory at transcript tab- $transcriptStr');

        final List<Map<String, String>> messages =
            parseTranscript(transcriptStr);

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            log('Processing message: $message');
            return ChatBoxWidget(
              speaker: message['speaker'] ?? 'Unknown Speaker',
              text: message['text'] ?? '',
            );
          },
        );
      },
    );
  }
}
