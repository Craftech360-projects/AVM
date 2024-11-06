import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:friend_private/backend/api_requests/api/llm.dart';
import 'package:friend_private/backend/api_requests/api/pinecone.dart';
import 'package:friend_private/backend/api_requests/api/prompt.dart';
import 'package:friend_private/backend/api_requests/api/random_memory_img.dart';
import 'package:friend_private/backend/database/geolocation.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/backend/database/prompt_provider.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/plugin.dart';
import 'package:friend_private/pages/capture/location_service.dart';
import 'package:friend_private/utils/features/calendar.dart';
import 'package:friend_private/utils/memories/integrations.dart';
import 'package:instabug_flutter/instabug_flutter.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:tuple/tuple.dart';
import 'package:friend_private/utils/memories/shoppingsuggestion.dart';

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
    Geolocation? geolocation =
        await locationService.getGeolocationDetails(); // Fetch geolocation

    debugPrint(">>>>>>>>>Geolocation fetched successfully,$Geolocation");
  } else {
    debugPrint("Geolocation permissions not granted or service disabled.");
  }
  if (transcript.isNotEmpty || photos.isNotEmpty) {
//should we do transcription diarize here?
    //TranscriptSegment
//log(transcriptSegments);

    final String message = """
I have a transcription of a conversation that I would like to speaker diarization. Please assign different sections of the transcription to individual users, and label them as Speaker 1, Speaker 2, and so on.

Additionally, if the transcription contains any irrelevant background noise or speech (e.g., a YouTube video playing or any non-conversational audio), please eliminate that data from the output.

Here is the transcription:

"${transcript}"

Please return the diarized transcript in JSON format with the following structure:

{
  diarized_transcript: [
    {
      "speaker": "Speaker 1",
      "text": "Section of transcript spoken by Speaker 1"
    },
    {
      "speaker": "Speaker 2",
      "text": "Section of transcript spoken by Speaker 2"
    },
    {
      "speaker": "Speaker N",
      "text": "Section of transcript spoken by Speaker N"
    }
  ],
 
}

Make sure each section of the transcription is labeled with the corresponding speaker, and that any unwanted background noise or irrelevant content is removed.
""";
    final String finalTranscript =
        await executeSpeechDiarizationPrompt(message);
    print("Diarized Transcript: $finalTranscript");
    transcript = finalTranscript;
    print(">>>>>>>>>>gont to summarize");

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
      print('is prompt saved $isPromptSaved');
      CustomPrompt? savedPrompt;
      if (isPromptSaved) {
        final prompt = PromptProvider().getPrompts().last;
        print('prompt fetched from object box ${prompt.toString()}');

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
  } catch (e, stacktrace) {
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
Future<Memory> memoryCreationBlock(
  BuildContext context,
  String transcript,
  List<TranscriptSegment> transcriptSegments,
  String? recordingFilePath,
  // Uint8List memoryImg,
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
        Structured('', '',
            emoji: '😢', category: ['failed']), // Wrap 'failed' in a list
        [],
      );
    }
  } else {}
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
    // Pass the productSuggestions
  );
  debugPrint('Memory created: ${memory.id}');

  if (!retrievedFromCache) {
    if (structured.title.isEmpty && !failed) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      showTopSnackBar(
        displayDuration: const Duration(milliseconds: 4000),
        Overlay.of(context),
        const CustomSnackBar.info(
          maxLines: 6,
          // textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          message:
              "Audio processing failed due to noise \n Please try again in a \n quieter place!",
        ),
      );
    } else if (structured.title.isNotEmpty) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(
          message: 'New memory created! 🚀',
        ),
      );
    } else {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.info(
          message: 'Memory stored as discarded! There\'s Background noise 😄',
        ),
      );
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
    print(
        "Geolocation Details: Latitude: ${geolocation.latitude}, Longitude: ${geolocation.longitude}, "
        "Address: ${geolocation.address}, Location Type: ${geolocation.locationType}, "
        "Google Place ID: ${geolocation.googlePlaceId}, "
        "Place: ${geolocation.placeName}");

    // Add geolocation to memory
    memory.geolocation.target = geolocation;
  } else {
    print("Geolocation is null.");
  }

  // Add transcript segments
  memory.transcriptSegments.addAll(transcriptSegments);

  // Assign structured data
  memory.structured.target = structured;

  // Print the memory object before saving for debugging
  print(">>KKKKKK>>>>Final Memory Object: ${memoryToString(memory)}");

  try {
    // Save the memory object
    MemoryProvider().saveMemory(memory);
    print("Success saving memory.");
  } catch (e) {
    print("Error saving memory: $e");
    // Handle the error as needed
  }

  // Process embeddings if not discarded
  if (!discarded) {
    getEmbeddingsFromInput(structured.toString()).then((vector) {
      upsertPineconeVector(memory.id.toString(), vector, memory.createdAt);
    });
  }

  // Optionally, track the memory creation
  // MixpanelManager().memoryCreated(memory);

  return memory;
}

// Helper function to print memory details as a string
String memoryToString(Memory memory) {
  print(memory);
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
