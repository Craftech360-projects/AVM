import 'package:AVMe/backend/preferences.dart';
import 'package:AVMe/utils/features/calendar.dart';
import 'package:flutter/material.dart';
import 'package:AVMe/backend/database/memory.dart';
import 'package:AVMe/backend/database/memory_provider.dart';
import 'package:AVMe/backend/mixpanel.dart';
import 'package:AVMe/backend/storage/memories.dart';
import 'package:instabug_flutter/instabug_flutter.dart';

import '/backend/api_requests/api_calls.dart';

// Perform actions periodically
Future<Memory?> processTranscriptContent(
    BuildContext context, String content, String? recordingFilePath,
    {bool retrievedFromCache = false,
    DateTime? startedAt,
    DateTime? finishedAt}) async {
  if (content.isNotEmpty) {
    return await memoryCreationBlock(
      context,
      content,
      recordingFilePath,
      retrievedFromCache,
      startedAt,
      finishedAt,
    );
  }
  return null;
}

// Process the creation of memory records
// Future<Memory?> memoryCreationBlock(
//   BuildContext context,
//   String transcript,
//   String? recordingFilePath,
//   bool retrievedFromCache,
//   DateTime? startedAt,
//   DateTime? finishedAt,
// ) async {
//   List<Memory> recentMemories =
//       await MemoryProvider().retrieveRecentMemoriesWithinMinutes(minutes: 10);
//   MemoryStructured structuredMemory;
//   try {
//     structuredMemory =
//         await generateTitleAndSummaryForMemory(transcript, recentMemories);
//   } catch (e) {
//     debugPrint('Error: $e');
//     InstabugLog.logError(e.toString());
//     if (!retrievedFromCache) {
//       ScaffoldMessenger.of(context).removeCurrentSnackBar();
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text(
//               'There was an error creating your memory, please check your open AI API keys.')));
//     }
//     return null;
//   }
//   debugPrint('Structured Memory: $structuredMemory');

//   if (structuredMemory.title.isEmpty) {
//     await saveFailureMemory(
//         transcript, structuredMemory, startedAt, finishedAt);
//     if (!retrievedFromCache) {
//       ScaffoldMessenger.of(context).removeCurrentSnackBar();
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text(
//           'Memory stored as discarded! Nothing useful. 😄',
//           style: TextStyle(color: Colors.white),
//         ),
//         duration: Duration(seconds: 4),
//       ));
//     }
//   } else {
//     Memory memory = await finalizeMemoryRecord(
//         transcript, structuredMemory, recordingFilePath, startedAt, finishedAt);
//     debugPrint('Memory created: ${memory.id}');
//     if (!retrievedFromCache) {
//       ScaffoldMessenger.of(context).removeCurrentSnackBar();
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('New memory created! 🚀',
//             style: TextStyle(color: Colors.white)),
//         duration: Duration(seconds: 4),
//       ));
//     }
//     return memory;
//   }
//   return null;
// }

//now adding data from action item, need to create events and add events later

Future<Memory?> memoryCreationBlock(
  BuildContext context,
  String transcript,
  String? recordingFilePath,
  bool retrievedFromCache,
  DateTime? startedAt,
  DateTime? finishedAt,
) async {
  List<Memory> recentMemories =
      await MemoryProvider().retrieveRecentMemoriesWithinMinutes(minutes: 10);
  MemoryStructured structuredMemory;
  try {
    structuredMemory =
        await generateTitleAndSummaryForMemory(transcript, recentMemories);
  } catch (e) {
    debugPrint('Error: $e');
    InstabugLog.logError(e.toString());
    if (!retrievedFromCache) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'There was an error creating your memory, please check your open AI API keys.')));
    }
    return null;
  }
  debugPrint('Structured Memory: $structuredMemory');

  if (structuredMemory.title.isEmpty) {
    await saveFailureMemory(
        transcript, structuredMemory, startedAt, finishedAt);
    if (!retrievedFromCache) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Memory stored as discarded! Nothing useful. 😄',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 4),
      ));
    }
  } else {
    // Process action items and add to calendar if enabled
    if (SharedPreferencesUtil().calendarEnabled &&
        SharedPreferencesUtil().deviceId.isNotEmpty &&
        SharedPreferencesUtil().calendarType == 'auto') {
      for (var i = 0; i < structuredMemory.actionItems.length; i++) {
        String actionItemDescription = structuredMemory.actionItems[i];
        DateTime dueDate =
            DateTime.now().add(Duration(days: 1)); // Default to tomorrow
        Duration duration = Duration(hours: 1); // Default duration

        if (SharedPreferencesUtil().calendarEnabled &&
            SharedPreferencesUtil().deviceId.isNotEmpty &&
            SharedPreferencesUtil().calendarType == 'auto') {
          for (var i = 0; i < structuredMemory.actionItems.length; i++) {
            String actionItemDescription = structuredMemory.actionItems[i];
            DateTime dueDate =
                DateTime.now().add(Duration(days: 1)); // Default to tomorrow
            int durationInMinutes = 60; // Default duration of 1 hour in minutes

            try {
              bool eventCreated = await CalendarUtil().createEvent(
                actionItemDescription,
                dueDate,
                durationInMinutes,
                description: 'Action item from memory',
              );
              // Update the action item with calendar event creation status
              structuredMemory.actionItems[i] =
                  '$actionItemDescription (Calendar event: ${eventCreated ? 'Created' : 'Failed'})';
            } catch (e) {
              debugPrint('Failed to create calendar event: $e');
              structuredMemory.actionItems[i] =
                  '$actionItemDescription (Calendar event: Failed)';
            }
          }
        }
      }
    }

    Memory memory = await finalizeMemoryRecord(
        transcript, structuredMemory, recordingFilePath, startedAt, finishedAt);
    debugPrint('Memory created: ${memory.id}');
    if (!retrievedFromCache) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('New memory created! 🚀',
            style: TextStyle(color: Colors.white)),
        duration: Duration(seconds: 4),
      ));
    }
    return memory;
  }
  return null;
}

// Save failure memory when structured memory contains empty string
Future<Memory> saveFailureMemory(
  String transcript,
  MemoryStructured structuredMemory,
  DateTime? startedAt,
  DateTime? finishedAt,
) async {
  Structured structured = Structured(
    structuredMemory.title,
    structuredMemory.overview,
    emoji: structuredMemory.emoji,
    category: structuredMemory.category,
  );
  Memory memory = Memory(DateTime.now(), transcript, true,
      startedAt: startedAt, finishedAt: finishedAt);
  memory.structured.target = structured;
  MemoryProvider().saveMemory(memory);
  MixpanelManager().memoryCreated(memory);
  return memory;
}

// Finalize memory record after processing feedback
Future<Memory> finalizeMemoryRecord(
  String transcript,
  MemoryStructured structuredMemory,
  String? recordingFilePath,
  DateTime? startedAt,
  DateTime? finishedAt,
) async {
  Structured structured = Structured(
    structuredMemory.title,
    structuredMemory.overview,
    emoji: structuredMemory.emoji,
    category: structuredMemory.category,
  );
  for (var actionItem in structuredMemory.actionItems) {
    structured.actionItems.add(ActionItem(actionItem));
  }
  var memory = Memory(DateTime.now(), transcript, false,
      recordingFilePath: recordingFilePath,
      startedAt: startedAt,
      finishedAt: finishedAt);
  memory.structured.target = structured;

  await MemoryProvider().saveMemory(memory);

  getEmbeddingsFromInput(structuredMemory.toString()).then((vector) {
    createPineconeVector(memory.id.toString(), vector);
  });
  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
  print(memory);
  return memory;
}
