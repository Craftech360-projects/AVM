import 'dart:developer';
import 'dart:typed_data';

import 'package:avm/backend/api_requests/api/other.dart';
//import 'package:avm/backend/api_requests/api/pinecone.dart';
import 'package:avm/backend/api_requests/api/prompt.dart';
import 'package:avm/backend/api_requests/api/random_memory_img.dart';
import 'package:avm/backend/database/geolocation.dart';
import 'package:avm/backend/database/memory.dart';
import 'package:avm/backend/database/memory_provider.dart';
import 'package:avm/backend/database/message.dart';
import 'package:avm/backend/database/prompt_provider.dart';
import 'package:avm/backend/database/transcript_segment.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/backend/schema/plugin.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/pages/capture/location_service.dart';
import 'package:avm/utils/features/backup_util.dart';
import 'package:avm/utils/features/calendar.dart';
import 'package:avm/utils/memories/integrations.dart';
import 'package:flutter/material.dart';
import 'package:instabug_flutter/instabug_flutter.dart';
import 'package:tuple/tuple.dart';

// Perform actions periodically
Future<Memory?> processTranscriptContent(
  BuildContext context,
  String transcript,
  List<TranscriptSegment> transcriptSegments,
  String? recordingFilePath, {
  bool retrievedFromCache = false,
  DateTime? startedAt,
  DateTime? finishedAt,
  Geolocation? geolocation,
  List<Tuple2<String, String>> photos = const [],
  Function(Message, Memory?)? sendMessageToChat,
}) async {
  LocationService locationService = LocationService();
  if (await locationService.hasPermission() &&
      await locationService.enableService()) {
    debugPrint(">>>>>>>>>Geolocation fetched successfully,$Geolocation");
  } else {
    debugPrint("Geolocation permissions not granted or service disabled.");
  }
  if (transcript.isNotEmpty || photos.isNotEmpty) {
    Memory? memory = await memoryCreationBlock(
      context,
      transcript,
      transcriptSegments,
      recordingFilePath,
      retrievedFromCache,
      startedAt,
      finishedAt,
      geolocation,
      photos,
    );
    log("Memory created: ${memory.geolocation.target != null ? 'Lat: ${memory.geolocation.target!.latitude}, Lon: ${memory.geolocation.target!.longitude}, Address: ${memory.geolocation.target!.address}' : 'No geolocation'}");
    MemoryProvider().saveMemory(memory);
    triggerMemoryCreatedEvents(memory, sendMessageToChat: sendMessageToChat);
    return memory;
  }
  return null;
}

Future<SummaryResult?> _retrieveStructure(
  BuildContext context,
  String transcript,
  List<Tuple2<String, String>> photos,
  bool retrievedFromCache, {
  bool ignoreCache = false,
}) async {
  SummaryResult summary;
  try {
    if (photos.isNotEmpty) {
      summary = await summarizePhotos(photos);
    } else {
      bool isPromptSaved = SharedPreferencesUtil().isPromptSaved;
      CustomPrompt? savedPrompt;
      if (isPromptSaved) {
        final prompt = PromptProvider().getPrompts().last;

        // Create a CustomPrompt using the fields from the saved prompt
        savedPrompt = CustomPrompt(
          prompt: prompt.prompt,
          title: prompt.title,
          overview: prompt.overview,
          // Set other fields to null or default values as they're not in the Prompt object
          actionItems: prompt.actionItem,
          category: prompt.category,
          calendar: prompt.calender,
        );
      }
      summary = await summarizeMemory(transcript, [],
          ignoreCache: ignoreCache, customPromptDetails: savedPrompt);
      debugPrint("its reached here ${summary.structured}");
      debugPrint("Structured content:");
      debugPrint("Title: ${summary.structured.title}");
      debugPrint("Overview: ${summary.structured.overview}");
      debugPrint("Action Items: ${summary.structured.actionItems}");
      debugPrint("Category: ${summary.structured.category}");
      debugPrint("Emoji: ${summary.structured.emoji}");
      debugPrint("Events: ${summary.structured.events}");

      debugPrint("Plugins Response:");
    }
  } catch (e) {
    debugPrint('Error: $e');
    // CrashReporting.reportHandledCrash(e, stacktrace,
    //     level: NonFatalExceptionLevel.error,
    //     userAttributes: {
    //       'transcript_length': transcript.length.toString(),
    //       'transcript_words': transcript.split(' ').length.toString(),
    //       'language': SharedPreferencesUtil().recordingsLanguage,
    //       'developer_mode_enabled':
    //           SharedPreferencesUtil().devModeEnabled.toString(),
    //       'dev_mode_has_api_key':
    //           (SharedPreferencesUtil().openAIApiKey != '').toString(),
    //     });
    return null;
  }
  return summary;
}

// Process the creation of memory records
// Future<Memory> memoryCreationBlock(
//   BuildContext context,
//   String transcript,
//   List<TranscriptSegment> transcriptSegments,
//   String? recordingFilePath,
//   // Uint8List memoryImg,
//   bool retrievedFromCache,
//   DateTime? startedAt,
//   DateTime? finishedAt,
//   Geolocation? geolocation,
//   List<Tuple2<String, String>> photos,
// ) async {
//   SummaryResult? summarizeResult =
//       await _retrieveStructure(context, transcript, photos, retrievedFromCache);
//   bool failed = false;
//   if (summarizeResult == null) {
//     summarizeResult = await _retrieveStructure(
//         context, transcript, photos, retrievedFromCache,
//         ignoreCache: true);
//     if (summarizeResult == null) {
//       failed = true;
//       summarizeResult = SummaryResult(
//         Structured('', '',
//             emoji: '😢', category: ['failed']), // Wrap 'failed' in a list
//         [],
//       );
//       if (!retrievedFromCache) {
//         InstabugLog.logError('Unable to create memory structure.');
//         ScaffoldMessenger.of(context).removeCurrentSnackBar();
//         showTopSnackBar(
//           Overlay.of(context),
//           const CustomSnackBar.error(
//             message:
//                 'Unexpected error creating your memory. Please check your discarded memories.',
//           ),
//         );
//         // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         //   content: Text(
//         //     'Unexpected error creating your memory. Please check your discarded memories.',
//         //     style: TextStyle(color: Colors.white),
//         //   ),
//         //   duration: Duration(seconds: 4),
//         // ));
//       }
//     }
//   }
//   Structured structured = summarizeResult.structured;

//   if (SharedPreferencesUtil().calendarEnabled &&
//       SharedPreferencesUtil().deviceId.isNotEmpty &&
//       SharedPreferencesUtil().calendarType == 'auto') {
//     for (var event in structured.events) {
//       event.created = await CalendarUtil().createEvent(
//           event.title, event.startsAt, event.duration,
//           description: event.description);
//     }
//   }
//   // Pass the event title as the prompt for image generation
//   final memoryImg =
//       await generateImageWithFallback(summarizeResult.structured.title);

//   debugPrint("going to save ,saving memory");

//   Memory memory = await finalizeMemoryRecord(
//     transcript,
//     transcriptSegments,
//     structured,
//     summarizeResult.pluginsResponse,
//     recordingFilePath,
//     memoryImg,
//     startedAt,
//     finishedAt,
//     structured.title.isEmpty,
//     geolocation,
//     photos,
//   );
//   debugPrint('Memory created: ${memory.id}');

//   if (!retrievedFromCache) {
//     if (structured.title.isEmpty && !failed) {
//       ScaffoldMessenger.of(context).removeCurrentSnackBar();
//       showTopSnackBar(
//         displayDuration: const Duration(milliseconds: 4000),
//         Overlay.of(context),
//         const CustomSnackBar.info(
//             maxLines: 6,
//             // textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
//             message:
//                 "Audio processing failed due to noise \n Please try again in a \n quieter place!",
//             backgroundColor: CustomColors.greyLight),
//       );
//       // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//       //   content: Text(
//       //     'Memory stored as discarded! Nothing useful. 😄',
//       //     style: TextStyle(color: Colors.white),
//       //   ),
//       //   duration: Duration(seconds: 4),
//       // ));
//     } else if (structured.title.isNotEmpty) {
//       ScaffoldMessenger.of(context).removeCurrentSnackBar();
//       showTopSnackBar(
//         Overlay.of(context),
//         const CustomSnackBar.success(
//             message: 'New memory created! 🚀',
//             backgroundColor: CustomColors.greyLavender),
//       );
//       // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//       //   content: Text('New memory created! 🚀',
//       //       style: TextStyle(color: Colors.white)),
//       //   duration: Duration(seconds: 4),
//       // ));
//     } else {
//       showTopSnackBar(
//         Overlay.of(context),
//         const CustomSnackBar.info(
//           message: 'Memory stored as discarded! There\'s Background noise 😄',
//         ),
//       );
//     }
//   }
//   return memory;
// }
Future<Memory> memoryCreationBlock(
  BuildContext context,
  String transcript,
  List<TranscriptSegment> transcriptSegments,
  String? recordingFilePath,
  bool retrievedFromCache,
  DateTime? startedAt,
  DateTime? finishedAt,
  Geolocation? geolocation,
  List<Tuple2<String, String>> photos,
) async {
  SummaryResult? summarizeResult =
      await _retrieveStructure(context, transcript, photos, retrievedFromCache);
  bool failed = false;
  if (summarizeResult == null) {
    summarizeResult = await _retrieveStructure(
        context, transcript, photos, retrievedFromCache,
        ignoreCache: true);
    if (summarizeResult == null) {
      failed = true;
      summarizeResult = SummaryResult(
        Structured('', '', emoji: '😢', category: ['failed']),
        [],
      );
      if (!retrievedFromCache) {
        InstabugLog.logError('Unable to create memory structure.');
        avmSnackBar(context,
            "Unexpected error creating your memory. Please check your discarded memories.");
      }
    }
  }
  Structured structured = summarizeResult.structured;

  if (SharedPreferencesUtil().calendarEnabled &&
      SharedPreferencesUtil().deviceId.isNotEmpty &&
      SharedPreferencesUtil().calendarType == 'auto') {
    for (var event in structured.events) {
      event.created = await CalendarUtil().createEvent(
          event.title, event.startsAt, event.duration,
          description: event.description);
    }
  }

  // Pass the event title as the prompt for image generation
  final memoryImg =
      await generateImageWithFallback(summarizeResult.structured.title);

  debugPrint("going to save ,saving memory");

  Memory memory = await finalizeMemoryRecord(
    transcript,
    transcriptSegments,
    structured,
    summarizeResult.pluginsResponse,
    recordingFilePath,
    memoryImg,
    startedAt,
    finishedAt,
    structured.title.isEmpty,
    geolocation,
    photos,
  );
  debugPrint('Memory created: ${memory.id}');

  if (!retrievedFromCache) {
    if (structured.title.isEmpty && !failed) {
      avmSnackBar(context,
          "Audio processing failed due to noise. Please try again in a quieter place!");
    } else if (structured.title.isNotEmpty) {
      bool backupsEnabled = SharedPreferencesUtil().backupsEnabled;
      avmSnackBar(context, "New memory created!");
      backupsEnabled ? manualBackup(context) : null;
    } else {
      avmSnackBar(
          context, "Memory stored as discarded due to background noise.");
    }
  }
  return memory;
}

// Finalize memory record after processing feedback
Future<Memory> finalizeMemoryRecord(
  String transcript,
  List<TranscriptSegment> transcriptSegments,
  Structured structured,
  List<Tuple2<Plugin, String>> pluginsResponse,
  String? recordingFilePath,
  Uint8List memoryImg,
  DateTime? startedAt,
  DateTime? finishedAt,
  bool discarded,
  Geolocation? geolocation,
  List<Tuple2<String, String>> photos,
) async {
  var memory = Memory(
    DateTime.now(),
    transcript,
    memoryImg,
    discarded,
    recordingFilePath: recordingFilePath,
    startedAt: startedAt,
    finishedAt: finishedAt,
  );

  // Step 2: Add geolocation if available
  if (geolocation != null) {
    // Print geolocation details for debugging

    // Add geolocation to memory
    memory.geolocation.target = geolocation;
  } else {}

  // Add transcript segments
  memory.transcriptSegments.addAll(transcriptSegments);

  // Assign structured data
  memory.structured.target = structured;

  // Add plugin responses

  //
  for (var r in pluginsResponse) {
    memory.pluginsResponse.add(PluginResponse(r.item2, pluginId: r.item1.id));
  }
  log("plugin response,${memory.pluginsResponse.toString()}");
  zapWebhookOnMemoryCreatedCall(memory, returnRawBody: true); // Add photos
  // for (var image in photos) {
  //   memory.photos.add(MemoryPhoto(image.item1, image.item2));
  // }

  // Print the memory object before saving for debugging

  try {
    // Save the memory object
    MemoryProvider().saveMemory(memory);
  } catch (e) {
    // Handle the error as needed
  }

  // Process embeddings if not discarded
  // if (!discarded) {
  //   getEmbeddingsFromInput(structured.toString()).then((vector) {
  //     upsertPineconeVector(memory.id.toString(), vector, memory.createdAt);
  //   });
  // }

  // Optionally, track the memory creation
  // MixpanelManager().memoryCreated(memory);

  return memory;
}

// Helper function to print memory details as a string
String memoryToString(Memory memory) {
  return '''
    Memory ID: ${memory.id}
    Created At: ${memory.createdAt}
    Transcript: ${memory.transcript}
    Discarded: ${memory.discarded}
    Recording File Path: ${memory.recordingFilePath ?? 'None'}
    Geolocation: ${memory.geolocation.target != null ? 'Lat: ${memory.geolocation.target!.latitude}, Lon: ${memory.geolocation.target!.longitude}, Address: ${memory.geolocation.target!.address}' : 'No geolocation'}
    Transcript Segments Count: ${memory.transcriptSegments.length}
    Structured Title: ${memory.structured.target?.title ?? 'No title'}
    
    ''';
}