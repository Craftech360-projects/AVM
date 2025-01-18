import 'package:capsaul/backend/api_requests/api/pinecone.dart';
import 'package:capsaul/backend/api_requests/api/prompt.dart';
import 'package:capsaul/backend/database/memory.dart';
import 'package:capsaul/backend/database/memory_provider.dart';
import 'package:capsaul/backend/mixpanel.dart';
import 'package:flutter/material.dart';

import '../../backend/database/prompt_provider.dart';
import '../../backend/preferences.dart';

Future<Memory?> reProcessMemory(
  BuildContext context,
  Memory memory,
  Function onFailedProcessing,
  Function changeLoadingState,
) async {
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
    // update instead if it wasn't "discarded"
    upsertPineconeVector(memory.id.toString(), vector, memory.createdAt);
  });

  MemoryProvider().updateMemoryStructured(structured);
  MemoryProvider().updateMemory(memory);
  changeLoadingState();
  MixpanelManager().reProcessMemory(memory);
  return memory;
}
