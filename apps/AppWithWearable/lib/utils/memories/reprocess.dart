import 'package:flutter/material.dart';
import 'package:friend_private/backend/api_requests/api/llm.dart';
import 'package:friend_private/backend/api_requests/api/pinecone.dart';
import 'package:friend_private/backend/api_requests/api/prompt.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:instabug_flutter/instabug_flutter.dart';

import '../../backend/database/prompt_provider.dart';
import '../../backend/preferences.dart';

Future<Memory?> reProcessMemory(
  BuildContext context,
  Memory memory,
  Function onFailedProcessing,
  Function changeLoadingState,
) async {
  debugPrint('_reProcessMemory');
  changeLoadingState();
  SummaryResult summaryResult;
  try {
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

    // Perform diarization on the transcript before summarizing
    // String diarizedTranscript = await diarizeTranscript(memory.transcript);
    // memory.transcript =
    //     diarizedTranscript; // Update the memory with diarized transcript
    final String message = """
I have a transcription of a conversation that I would like to diarize. Please assign different sections of the transcription to individual users, and label them as Speaker 1, Speaker 2, and so on.

Additionally, if the transcription contains any irrelevant background noise or speech (e.g., a YouTube video playing or any non-conversational audio), please eliminate that data from the output.

Here is the transcription:

"${memory.transcript}"

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
  "irrelevant_data_removed": "true or false"
}

Make sure each section of the transcription is labeled with the corresponding speaker, and that any unwanted background noise or irrelevant content is removed.
""";
    final dynamic finalTranscript =
        await executeSpeechDiarizationPrompt(message);
    print("Diarized Transcript: $finalTranscript");
    memory.transcript = finalTranscript;
    summaryResult = await summarizeMemory(memory.transcript, [],
        forceProcess: true,
        conversationDate: memory.createdAt,
        customPromptDetails: savedPrompt);
  } catch (err, stacktrace) {
    print(err);
    var memoryReporting = MixpanelManager().getMemoryEventProperties(memory);
    // CrashReporting.reportHandledCrash(err, stacktrace,
    //     level: NonFatalExceptionLevel.critical,
    //     userAttributes: {
    //       'memory_transcript_length':
    //           memoryReporting['transcript_length'].toString(),
    //       'memory_transcript_word_count':
    //           memoryReporting['transcript_word_count'].toString(),
    //       // 'memory_transcript_language': memoryReporting['transcript_language'], // TODO: this is incorrect
    //     });
    onFailedProcessing();
    changeLoadingState();
    return null;
  }
  // TODO: move this to a method from structured?
  Structured structured = memory.structured.target!;
  Structured newStructured = summaryResult.structured;
  structured.title = newStructured.title;
  structured.overview = newStructured.overview;
  structured.emoji = newStructured.emoji;
  structured.category = newStructured.category;

  structured.actionItems.clear();
  structured.actionItems.addAll(newStructured.actionItems
      .map<ActionItem>((i) => ActionItem(i.description))
      .toList());

  structured.events.clear();
  for (var event in newStructured.events) {
    structured.events.add(Event(event.title, event.startsAt, event.duration,
        description: event.description));
  }

  memory.structured.target = structured;
  memory.discarded = false;
  memory.pluginsResponse.clear();
  memory.pluginsResponse.addAll(
    summaryResult.pluginsResponse
        .map<PluginResponse>(
            (e) => PluginResponse(e.item2, pluginId: e.item1.id))
        .toList(),
  );

  // Add Calendar Events

  getEmbeddingsFromInput(structured.toString()).then((vector) {
    // TODO: update instead if it wasn't "discarded"
    upsertPineconeVector(memory.id.toString(), vector, memory.createdAt);
  });

  MemoryProvider().updateMemoryStructured(structured);
  MemoryProvider().updateMemory(memory);
  debugPrint('MemoryProvider().updateMemory');
  changeLoadingState();
  MixpanelManager().reProcessMemory(memory);
  return memory;
}
