import 'package:AVMe/backend/preferences.dart';
import 'package:AVMe/utils/features/calendar.dart';
import 'package:AVMe/utils/memory_structured.dart';
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
  print("adding to calendar>>>>>start");
  List<Memory> recentMemories =
      await MemoryProvider().retrieveRecentMemoriesWithinMinutes(minutes: 10);
  MemoryStructured structuredMemory;
  try {
    print("recentMemories");

    print(recentMemories);
    print(transcript);
    // structuredMemory = dummyStructuredMemory;
    // print("dummny added");

    structuredMemory =
        await generateTitleAndSummaryForMemory(transcript, recentMemories);
    print("structuredMemory>>>>>>>>>>>>>:$structuredMemory");
  } catch (e) {
    debugPrint('Error: $e');
    InstabugLog.logError(e.toString());
    if (!retrievedFromCache) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'There was an error creating your memory, please check your open AI API keys.')));
    } else {
      print(retrievedFromCache);
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
    print("adding to calendar");
    // Process action items and add to calendar if enabled
    if (SharedPreferencesUtil().calendarEnabled &&
        SharedPreferencesUtil().deviceId.isNotEmpty &&
        SharedPreferencesUtil().calendarType == 'auto') {
      print("here>>>11");
      CalendarUtil calendarUtil = CalendarUtil();
      for (var i = 0; i < structuredMemory.events.length; i++) {
        var event = structuredMemory.events[i];
        String title = event.title;
        DateTime startsAt = event.startsAt;
        int durationInMinutes = event.duration;
        String description = event.description ?? 'Event from memory';

        print('Processing event: $title');

        try {
          print("Calling createEvent method");
          print("Title: $title");
          print("StartsAt: $startsAt");
          print("Duration: $durationInMinutes minutes");
          print("Description: $description");

          bool eventCreated = await calendarUtil.createEvent(
            title,
            startsAt,
            durationInMinutes,
            description: description,
          );

          print("Event creation result: $eventCreated");

          // Update the event with calendar event creation status
          structuredMemory.events[i].created = eventCreated;
        } catch (e) {
          print("Failed to create calendar event: $e");
          structuredMemory.events[i].created = false;
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
