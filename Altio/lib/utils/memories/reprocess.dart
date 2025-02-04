import 'dart:developer';

import 'package:altio/backend/api_requests/api/pinecone.dart';
import 'package:altio/backend/api_requests/api/prompt.dart';
import 'package:altio/backend/database/memory.dart';
import 'package:altio/backend/database/memory_provider.dart';
import 'package:altio/backend/mixpanel.dart';
import 'package:altio/utils/features/calendar.dart';
import 'package:altio/utils/memories/process.dart';
import 'package:flutter/material.dart';

import '../../backend/database/prompt_provider.dart';
import '../../backend/preferences.dart';

Future<Memory?> reProcessMemory(
  BuildContext context,
  Memory memory,
  Function onFailedProcessing,
  Function changeLoadingState,
) async {
  try {
    changeLoadingState();
    SummaryResult summaryResult;
    try {
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
      summaryResult = await summarizeMemory(memory.transcript, [],
          forceProcess: true,
          conversationDate: memory.createdAt,
          customPromptDetails: savedPrompt);
    } catch (err) {
      MixpanelManager().getMemoryEventProperties(memory);
      onFailedProcessing();
      changeLoadingState();
      return null;
    }
    // move this to a method from structured?
    Structured structured = memory.structured.target!;
    Structured newStructured = summaryResult.structured;
    structured.title = newStructured.title;
    structured.overview = newStructured.overview;
    structured.emoji = newStructured.emoji;
    structured.category = newStructured.category;
    structured.brainstormingQuestions = newStructured.brainstormingQuestions;

    if (newStructured.profileInsights != null) {
      structured.profileInsights =
          Map<String, dynamic>.from(newStructured.profileInsights!);
    }

    structured.actionItems
      ..clear()
      ..addAll(newStructured.actionItems.map((i) => ActionItem(i.description)));

    structured.events
      ..clear()
      ..addAll(newStructured.events.map((e) =>
          Event(e.title, e.startsAt, e.duration, description: e.description)));

    memory.structured.target = structured;
    memory.discarded = false;
    memory.pluginsResponse.clear();
    memory.pluginsResponse.addAll(
      summaryResult.pluginsResponse
          .map<PluginResponse>(
              (e) => PluginResponse(e.item2, pluginId: e.item1.id))
          .toList(),
    );

    // Update user profile with new insights
    await updateUserProfile(structured);

    // Update calendar events if needed
    if (SharedPreferencesUtil().calendarEnabled) {
      for (var event in structured.events) {
        event.created = await CalendarUtil().createEvent(
            event.title, event.startsAt, event.duration,
            description: event.description);
      }
    }

    getEmbeddingsFromInput(structured.toString()).then((vector) {
      // update instead if it wasn't "discarded"
      // upsertPineconeVector(memory.id.toString(), vector, memory.createdAt);
    });

    // Persist changes
    MemoryProvider().updateMemoryStructured(structured);
    MemoryProvider().updateMemory(memory);

    // Analytics
    MixpanelManager().reProcessMemory(memory);

    return memory;
  } catch (err, stack) {
    log('Reprocessing Error', error: err, stackTrace: stack);
    MixpanelManager().track(err.toString());
    onFailedProcessing();
    return null;
  } finally {
    changeLoadingState();
  }
}
