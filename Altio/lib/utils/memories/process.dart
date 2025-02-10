import 'dart:developer';
import 'dart:typed_data';

import 'package:altio/backend/api_requests/api/other.dart';
import 'package:altio/backend/api_requests/api/prompt.dart';
import 'package:altio/backend/api_requests/api/random_memory_img.dart';
import 'package:altio/backend/database/geolocation.dart';
import 'package:altio/backend/database/memory.dart';
import 'package:altio/backend/database/memory_provider.dart';
import 'package:altio/backend/database/message.dart';
import 'package:altio/backend/database/profile_entity.dart';
import 'package:altio/backend/database/prompt_provider.dart';
import 'package:altio/backend/database/transcript_segment.dart';
import 'package:altio/backend/preferences.dart';
import 'package:altio/backend/schema/plugin.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/utils/features/backup_util.dart';
import 'package:altio/utils/features/calendar.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../../backend/database/box.dart';

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
  // Existing logic to create memory
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

  return memory;
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
    }
  } catch (e) {
    log('Error: $e');
    return null;
  }
  return summary;
}

Future<Memory?> memoryCreationBlock(
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
    if (!context.mounted) return null;
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
        if (!context.mounted) return null;
        avmSnackBar(context,
            "Unexpected error creating your memory. Please check your discarded memories.");
      }
    }
  }
  Structured structured = summarizeResult.structured;
  // print("Structured in Process: ${structured.profileInsights?.entries}");

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

  updateUserProfile(structured);

  if (!retrievedFromCache) {
    if (structured.title.isEmpty && !failed) {
      if (context.mounted) {
        avmSnackBar(context,
            "Audio processing failed due to noise. Please try again in a quieter place!");
      }
    } else if (structured.title.isNotEmpty) {
      bool backupsEnabled = SharedPreferencesUtil().backupsEnabled;
      if (context.mounted) {
        avmSnackBar(context, "New memory created!");
      }
      if (backupsEnabled && context.mounted) {
        manualBackup(context);
      }
    } else {
      if (context.mounted) {
        avmSnackBar(
            context, "Memory stored as discarded due to background noise.");
      }
    }
  }

  return memory;
}

// Update the updateUserProfile function in process.dart
Future<void> updateUserProfile(Structured structured) async {
  try {
    final box = ObjectBoxUtil().box!.store.box<Profile>();
    Profile profile = box.get(1) ?? Profile();

    // Update categories
    profile.categories = <String>{
      ...profile.categories.whereType<String>(),
      ...structured.category.whereType<String>()
    }.toList();

    // Merge new insights
    if (structured.profileInsights != null) {
      profile.mergeInsights(structured.profileInsights!);
    }

    if (structured.conversationMetrics.isNotEmpty) {
      profile.conversationMetrics = structured.conversationMetrics;
    } else {
      log("⚠️ Warning: Received empty conversation metrics, keeping existing values.");
    }

    profile.lastUpdated = DateTime.now();

    // Update emoji if new one exists
    if (structured.emoji.isNotEmpty) {
      profile.emoji = structured.emoji;
    }

    box.put(profile);
  } catch (e, stack) {
    log("❌ Error updating profile: $e", stackTrace: stack);
  }
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
  zapWebhookOnMemoryCreatedCall(memory, returnRawBody: true);

  try {
    // Save the memory object
    MemoryProvider().saveMemory(memory);
  } catch (e) {
    // Handle the error as needed
  }

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
