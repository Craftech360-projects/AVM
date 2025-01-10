// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:capsoul/backend/api_requests/api/llm.dart';
import 'package:capsoul/backend/database/memory.dart';
import 'package:capsoul/backend/database/message.dart';
import 'package:capsoul/backend/database/prompt_provider.dart';
import 'package:capsoul/backend/preferences.dart';
import 'package:capsoul/backend/schema/plugin.dart';
import 'package:capsoul/utils/features/calendar.dart';
import 'package:capsoul/utils/other/string_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class SummaryResult {
  final Structured structured;
  final List<Tuple2<Plugin, String>> pluginsResponse;

  SummaryResult(this.structured, this.pluginsResponse);
}

class CustomPrompt {
  final String? prompt;
  final String? title;
  final String? overview;
  final String? actionItems;
  final String? category;
  final String? calendar;

  CustomPrompt({
    this.prompt,
    this.title,
    this.overview,
    this.actionItems,
    this.category,
    this.calendar,
  });

  @override
  String toString() {
    return 'CustomPrompt(prompt: $prompt, title: $title, overview: $overview, actionItems: $actionItems, category: $category, calendar: $calendar)';
  }
}

Future<SummaryResult> summarizeMemory(
  String transcript,
  List<Memory> previousMemories, {
  bool forceProcess = false,
  bool ignoreCache = false,
  DateTime? conversationDate,
  CustomPrompt? customPromptDetails,
}) async {
  bool isPromptSaved = SharedPreferencesUtil().isPromptSaved;
  if (isPromptSaved) {
    final prompt = PromptProvider().getPrompts().first;
  }

  debugPrint('summarizeMemory transcript length: ${transcript.length}');
  if (transcript.isEmpty || transcript.split(' ').length < 7) {
    return SummaryResult(Structured('', ''), []);
  }

  if (transcript.split(' ').length > 6) {
    forceProcess = true;
  }

  var prompt = '''
Summarize the following conversation transcript. The conversation language is ${SharedPreferencesUtil().recordingsLanguage}. Respond in English.

${forceProcess ? "" : "If the conversation does not contain significant insights or action items, output an empty title."}

**Key Instructions**: 
- Provide a detailed summary of the conversation, capturing the most important discussion points, insights, decisions, and commitments.
- Ensure the summary is comprehensive and does not omit critical details.
- Summaries should not be too brief. The overview must contain at least 100 words, and key highlights should provide enough context to understand the depth of the discussion.
- If the transcript contains the phrase "Remind me to", extract the reminder that follows and include it in the "reminders" field.
- For each reminder, generate a detailed **description** that includes the **purpose**, **time**, **place**, and any additional context mentioned in the transcript.
- Extract **date and time** from the reminder text if specified, and include it in the "time" field in ISO8601 format. Use natural language understanding to interpret phrases like "tomorrow at 5 PM" or "next Monday at 3 PM" and convert them to ISO8601 format. If no specific time is mentioned, leave the field as `null`.
- Format the reminder as: {"reminder": "string", "description": "string", "time": "string (optional, e.g., ISO8601 date string)"}

Provide the following:
1. **Title**: ${customPromptDetails?.title ?? 'The main topic or most important theme of the conversation.'}
2. **Overview**: ${customPromptDetails?.overview ?? 'A detailed summary (minimum 100 words) of the key points and most significant details discussed, including decisions and major insights.'}
3. **Action Items**: ${customPromptDetails?.actionItems ?? 'A detailed list of tasks or commitments, including the context or reason behind each task, along with who is responsible for them and any deadlines.'}
4. **Category**: ${customPromptDetails?.category ?? 'Classify the conversation under up to 3 categories (personal, education, health, finance, legal, philosophy, spiritual, science, entrepreneurship, parenting, romantic, travel, inspiration, technology, business, social, work, other).'}
5. **Emoji**: A single emoji that represents the conversation theme.
6. **Calendar Events**: ${customPromptDetails?.calendar ?? 'Any specific events mentioned during the conversation. Include the title, description, start time, and duration.'}
7. **Reminders**: Include reminders as an array. Each reminder should have:
   - **Reminder**: A brief title of the reminder.
   - **Description**: A detailed description including the purpose, time, place, and additional context from the transcript.
   - **Time**: A specific time or time range if mentioned in the transcript in ISO8601 format.

The date context for this conversation is ${DateTime.now().toIso8601String()}.


Transcript: ${transcript.trim()}

Respond in a JSON format with the following structure:
{
  "title": "string",
  "overview": "string",
  "action_items": [
    {
      "task": "string",
      "responsible": "string"
    }
  ],
  "reminders": [
    {
      "reminder": "string",
      "description": "string",
      "time": "string"
    }
  ],
  "category": [{"string"}],
  "emoji": "string",
  "events": [
    {
      "title": "string",
      "description": "string",
      "start_time": "ISO8601 date string",
      "duration": number
    }
  ]
}
''';

  var structuredResponse =
      extractJson(await executeGptPrompt(prompt, ignoreCache: ignoreCache));

  try {
    // Parse structuredResponse as JSON
    var parsedResponse = jsonDecode(structuredResponse);

    var structured = Structured.fromJson(parsedResponse);

    if (parsedResponse['reminders'] != null &&
        parsedResponse['reminders'].isNotEmpty) {
      for (var reminder in parsedResponse['reminders']) {
        String reminderText = reminder['reminder'];
        String description =
            reminder['description'] ?? 'No description provided';
        String? timeString = reminder['time'];
        DateTime? startsAt;

        // Parse the time string into DateTime
        if (timeString != null && timeString.isNotEmpty) {
          startsAt = DateTime.parse(timeString);
        }

        if (startsAt != null) {
          bool eventCreated = await CalendarUtil().createEvent(
            reminderText,
            startsAt,
            60, // Default duration of 1 hour, can be customized
            description: description,
          );

          if (eventCreated) {
            debugPrint('Reminder added to calendar: $reminderText');
          } else {
            debugPrint('Failed to add reminder to calendar: $reminderText');
          }
        } else {
          debugPrint('Invalid or missing time for reminder: $reminderText');
        }
      }
    }

    var pluginsResponse = await executePlugins(transcript);
    if (structured.title.isEmpty) return SummaryResult(structured, []);

    return SummaryResult(structured, pluginsResponse);
  } catch (e) {
    debugPrint("error, $e");
    return SummaryResult(Structured('', ''), []);
  }
}

Future<List<Tuple2<Plugin, String>>> executePlugins(String transcript) async {
  final pluginsList = SharedPreferencesUtil().pluginsList;
  final pluginsEnabled = SharedPreferencesUtil().pluginsEnabled;
  final enabledPlugins = pluginsList
      .where((e) => pluginsEnabled.contains(e.id) && e.worksWithMemories())
      .toList();
  // include memory details parsed already as extra context?
  // improve plugin result, include result + id to map it to.
  List<Future<Tuple2<Plugin, String>>> pluginPrompts = enabledPlugins.map(
    (plugin) async {
      try {
        // tweak with user name in anyway?
        String response = await executeGptPluginPrompt('''
        Your are an AI with the following characteristics:
        Name: ${plugin.name}, 
        Description: ${plugin.description},
        Task: ${plugin.memoryPrompt}
        
        Note: It is possible that the conversation you are given, has nothing to do with your task, 
        in that case, output an empty string. (For example, you are given a business conversation, but your task is medical analysis)
        
        Conversation: ```${transcript.trim()}```,
       
        Output your response in plain text, without markdown.
        Make sure to be concise and clear.
        '''
            .replaceAll('     ', '')
            .replaceAll('    ', '')
            .trim());

        return Tuple2(
            plugin, response.replaceAll('```', '').replaceAll('""', '').trim());
      } catch (e) {
        debugPrint('Error executing plugin ${plugin.id},$e');
        return Tuple2(plugin, '');
      }
    },
  ).toList();

  Future<List<Tuple2<Plugin, String>>> allPluginResponses =
      Future.wait(pluginPrompts);
  try {
    var responses = await allPluginResponses;
    return responses.where((e) => e.item2.length > 5).toList();
  } catch (e) {
    return [];
  }
}

Future<String> triggerTestMemoryPrompt(String prompt, String transcript) async {
  return await executeGptPrompt('''
        Your are an AI with the following characteristics:
        Task: $prompt
        
        Note: It is possible that the conversation you are given, has nothing to do with your task, 
        in that case, output an empty string. (For example, you are given a business conversation, but your task is medical analysis)
        
        Conversation: ```${transcript.trim()}```,
       
        Output your response in plain text, without markdown.
        Make sure to be concise and clear.
        '''
      .replaceAll('     ', '')
      .replaceAll('    ', '')
      .trim());
}

Future<List<String>> getSemanticSummariesForEmbedding(String transcript) async {
  var prompt = '''
  Please analyze the following transcript and identify the distinct topics discussed within the conversation.  
  For each identified topic, provide a detailed summary that captures the key points and important details. 
  Ensure that each summary is comprehensive yet concise, reflecting the main ideas and any relevant subtopics. 
  Separate each topic summary clearly using '###' as a delimiter. Aim for each summary to be between 100-150 words.
  
  Example Transcript:
  Speaker 1: Hi, how are you doing today?
  Speaker 2: I'm good, thanks. I wanted to discuss our plans for the upcoming project.
  Speaker 1: Sure, let's dive in.
  Speaker 2: First, we need to outline the key deliverables and timelines. I think the initial prototype should be ready by the end of next month.
  Speaker 1: That sounds reasonable. What about the budget? Do we have an estimate yet?
  Speaker 2: We're looking at around \$50,000 for the initial phase. This includes development, testing, and some marketing.
  Speaker 1: We should also consider potential risks, like delays in development or additional costs for unforeseen issues.
  Speaker 2: Definitely. We need a risk management plan to address these possibilities.
  ...
  Speaker 1: That’s a good point. We should also consider the budget implications.
  
  Example of Desired Output:
  Topic 1: Project Planning and Timeline
  Summary: Discussed the upcoming project, focusing on the key deliverables and timelines. Agreed that the initial prototype should be ready by the end of next month. Emphasized the importance of outlining key tasks and milestones to ensure timely progress.
  ###
  Topic 2: Budget and Financial Considerations
  Summary: Estimated a budget of around \$50,000 for the initial phase, covering development, testing, and marketing. Highlighted the need to consider potential risks, such as delays in development and additional costs for unforeseen issues. Discussed the importance of a risk management plan to mitigate these risks.
  ###
  Topic 3: Risk Management
  Summary: Identified potential risks including development delays and unforeseen costs. Stressed the importance of creating a risk management plan to address these challenges proactively. Discussed strategies for monitoring and mitigating risks throughout the project lifecycle.
  ###
  
  Transcript:
  $transcript
  '''
      .replaceAll('  ', '')
      .trim();
  // debugPrint(prompt);
  var response = await executeGptPrompt(prompt);

  return response
      .split('###')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

Future<String> generateFriendlyReply(String transcript) async {
  var prompt = '''
  You are his close friend. Your task is to provide friendly, funny and personalized comments on the conversation.
Here are some guidelines to follow
- Be informal, use humour, and make it personal, share your thoughts just like a good friend would.
- Do not write in a formal tone, write as if you are talking to a friend, (use lowercase, slang, etc.).
- Speak Directly to  him - no analysis or third-person commentary
- Keep it under 300 chars
- Use simple, everyday words  like you're talking to a friend
- Reference specific details from what the user said
- Be positive, supportive, and encouraging and don't be crying or overly emotional 
- be chill and relaxed, like you're having a casual conversation 
- respond like humans in a real conversation, not  like a robot
- you can also use some slight humour, sarcasm, teasing or light, funny insults if it fits the context
- you may also criticize or disagree with the user, but do it in a friendly, non -judgemental way
- make sure not to get the user down or make them feel bad
- do not ask any questions since you will not be able to understand the context in the next request
- You can  keep it short if you want to, sometimes a short response is better

Respond in a JSON format with the following structure:
  {
    "reply": "Desired Output"
  }
  
  his conversation is:
  $transcript
  '''
      .replaceAll('  ', '')
      .trim();

  debugPrint(prompt);
  var response = await executeGptPrompt(prompt);

  return response;
}

Future<String> postMemoryCreationNotification(Memory memory) async {
  if (memory.structured.target!.title.isEmpty) return '';
  if (memory.structured.target!.actionItems.isEmpty) return '';

  var userName = SharedPreferencesUtil().givenName;
  var str = userName.isEmpty
      ? 'a busy entrepreneur'
      : '$userName (a busy entrepreneur)';
  var prompt = '''
  The following is the structuring from a transcript of a conversation that just finished.
  First determine if there's crucial feedback to notify $str about it.
  If not, simply output an empty string, but if it is important, output 20 words (at most) with the most important feedback for the conversation.
  Be short, concise, and helpful, and specially strict on determining if it's worth notifying or not.
   
  Transcript:
  ${memory.transcript}
  
  Structured version:
  ${memory.structured.target!.toJson()}
  ''';
  debugPrint(prompt);
  var result = await executeGptPrompt(prompt);
  debugPrint('postMemoryCreationNotification result: $result');
  if (result.contains('N/A') || result.split(' ').length < 5) return '';
  return result.replaceAll('```', '').trim();
}

Future<String> dailySummaryNotifications(List<Memory> memories) async {
  var msg =
      'There were no memories today, don\'t forget to wear your Capsoul tomorrow';
  if (memories.isEmpty) return msg;
  if (memories.where((m) => !m.discarded).length <= 1) return msg;
  var str = SharedPreferencesUtil().givenName.isEmpty
      ? 'the user'
      : SharedPreferencesUtil().givenName;
  var prompt = '''
  The following are a list of $str's memories from today, with the transcripts and their respective structuring, that $str had during the day.
  $str wants to get a detailed summary of the key action items he has to take based on today's memories.

  Please provide a summary that includes:
  - A brief overview of the day's events.
  - Key action items with specific details and deadlines if mentioned.
  - Any important notes or observations.
  - Recommendations or next steps based on the memories.

  Remember, $str is busy, so this has to be very efficient and concise.
  Respond in at most 150 words.

  Output your response in plain text format.
  ```
  ${Memory.memoriesToString(memories, includeTranscript: true)}
  ```
  ''';
  debugPrint(prompt);

  //var result = await executeGptPrompt(prompt);

  var result = await executeGptPromptPlainText(prompt);
  debugPrint('dailySummaryNotifications result: $result');
  return result.replaceAll('```', '').trim();
}

// ------

//this below will work with llama

Future<Tuple2<List<String>, List<DateTime>>?> determineRequiresContext(
    List<Message> messages) async {
  String message = '''
        Based on the current conversation an AI and a User are having, determine if the AI requires context outside the conversation to respond to the user's message.
        More context could mean, user stored old conversations, notes, or information that seems very user-specific.
        
        - First determine if the conversation requires context, in the field "requires_context".
        - Context could be 2 different things:
          - A list of topics (each topic being 1 or 2 words, example are "Startups" "Funding" "Business Meeting" "Artificial Intelligence") that are going to be used to retrieve more context, in the field "topics". Leave an empty list if no context is needed.
          - A dates range, if the context is time-based, in the field "dates_range". Leave an empty list if no context is needed. FYI, if the user mentions "today," "todays," or "today's," it should be interpreted as ${DateTime.now().toIso8601String()} (from midnight 12am to next day midnight 12). Similarly, handle variations for "tomorrow" and "yesterday" based on their respective dates.

        Conversation:
        ${Message.getMessagesAsString(messages)}
        
        The output should be formatted as a JSON instance that conforms to the JSON schema below.
        
        Here is the output schema:
        ```
        {"properties": {"requires_context": {"title": "Requires Context", "description": "Based on the conversation, this tells if context is needed to respond", "default": false, "type": "string"}, "topics": {"title": "Topics", "description": "If context is required, the topics to retrieve context from", "default": [], "type": "array", "items": {"type": "string"}}, "dates_range": {"title": "Dates Range", "description": "The dates range to retrieve context from", "default": [], "type": "array", "minItems": 2, "maxItems": 2, "items": [{"type": "string", "format": "date-time"}, {"type": "string", "format": "date-time"}]}}}
        ```
        '''
      .replaceAll('        ', '');
  debugPrint('determineRequiresContext message: $message');
  var response = await executeGptPrompt(message);
  debugPrint('determineRequiresContext response: $response');

  // Use a regex to find and extract the JSON part from the response
  var jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(response);
  if (jsonMatch == null) {
    debugPrint('No JSON found in response');
    return null;
  }

  var cleanedResponse = jsonMatch.group(0)!;

  try {
    var data = jsonDecode(cleanedResponse);
    debugPrint(">>>>>>>clean data: $data");

    List<String> topics =
        data['topics'].map<String>((e) => e.toString()).toList();
    List<String> datesRange =
        data['dates_range'].map<String>((e) => e.toString()).toList();
    List<DateTime> dates = datesRange.map((e) => DateTime.parse(e)).toList();
    debugPrint('topics: $topics, dates: $dates');
    return Tuple2<List<String>, List<DateTime>>(topics, dates);
  } catch (e) {
    debugPrint('Error determining requires context: $e');
    return null;
  }
}

String qaRagPrompt(String context, List<Message> messages, {Plugin? plugin}) {
  // debugPrint("Your name is>>>>>>>>>>>>>>>>>>>: ${plugin.name}");
  List<Plugin> plugins = [];
  plugins = SharedPreferencesUtil().pluginsList;
  var selectedChatPlugin = SharedPreferencesUtil().selectedChatPluginId;
  var plugin = plugins.firstWhereOrNull((p) => selectedChatPlugin == p.id);
  if (selectedChatPlugin != 'no_selected' &&
      (plugin == null || !plugin.worksWithChat())) {
    SharedPreferencesUtil().selectedChatPluginId = 'no_selected';
  }
  if (plugin != null) {
    debugPrint("Your name is>>>>>>>>>>>>>>>>>>>: ${plugin.name}");
  } else {
    debugPrint("Plugin or plugin name is null");
  }

  var prompt = '''
    You are an assistant for question-answering tasks. Use the following pieces of retrieved context and the conversation history to continue the conversation.
    If you don't know the answer, just say that you didn't find any related information or you that don't know. Use three sentences maximum and keep the answer concise.
    If the message doesn't require context, it will be empty, so answer the question casually. if the user mentions "today," "todays," or "today's," it should be interpreted as ${DateTime.now().toIso8601String()} (from midnight 12am to next day midnight 12). Similarly, handle variations for "tomorrow" and "yesterday" based on their respective dates.
    ${plugin == null ? '' : '\nYour name is: ${plugin.name}, and your personality/description is "${plugin.description}".\nMake sure to reflect your personality in your response.\n'}
    Conversation History:
    ${Message.getMessagesAsString(messages, useUserNameIfAvailable: true, usePluginNameIfAvailable: true)}

    Context:
    ```
    $context
    ```
    Answer:
    '''
      .replaceAll('    ', '');
  debugPrint(prompt);
  return prompt;
}

Future<String> getInitialPluginPrompt(Plugin? plugin) async {
  if (plugin == null) {
    return '''
        Your are an AI with the following characteristics:
        Name: Capsoul, 
        Personality/Description: A friendly and helpful AI assistant that aims to make your life easier and more enjoyable.
        Task: Provide assistance, answer questions, and engage in meaningful conversations.
        
        Send an initial message to start the conversation, make sure this message reflects your personality, 
        humor, and characteristics.
       
        Output your response in plain text, without markdown, and it should be below 50 words.
    ''';
  }
  return '''
        Your are an AI with the following characteristics:
        Name: ${plugin.name}, 
        Personality/Description: ${plugin.chatPrompt},
        Task: ${plugin.memoryPrompt}
        
        Send an initial message to start the conversation, make sure this message reflects your personality, 
        humor, and characteristics.
       
        Output your response in plain text, without markdown.
        '''
      .replaceAll('     ', '')
      .replaceAll('    ', '')
      .trim();
}

Future<String> getPhotoDescription(Uint8List data) async {
  var messages = [
    {
      'role': 'user',
      'content': [
        {'type': "text", 'text': "What’s in this image?"},
        {
          'type': "image_url",
          'image_url': {"url": "data:image/jpeg;base64,${base64Encode(data)}"},
        },
      ],
    },
  ];
  return await gptApiCall(model: 'gpt-4o', messages: messages, maxTokens: 100);
}

// another thought is to ask gpt for a list of "scenes", so each one could be stored independently in vectors
Future<List<int>> determineImagesToKeep(
    List<Tuple2<Uint8List, String>> images) async {
  // was thinking here to take all images, and based on description, filter the ones that do not have repeated descriptions.
  String prompt = '''
  You will be provided with a list of descriptions of images that were taken from POV, with 5 seconds difference between each photo.
  
  Your task is to discard the repeated pictures, and output the indexes of the images that do not refer to the same scene, keeping only 1 description for the scene (so 1 index).
  
  Images: [${images.map((e) => "\"${e.item2}\"").join(', ')}]
  
  The output should be formatted as a JSON instance that conforms to the JSON schema below.

  As an example, for the schema {"properties": {"foo": {"title": "Foo", "description": "a list of strings", "type": "array", "items": {"type": "string"}}}, "required": ["foo"]}
  the object {"foo": ["bar", "baz"]} is a well-formatted instance of the schema. The object {"properties": {"foo": ["bar", "baz"]}} is not well-formatted.
  
  Here is the output schema:
  ```
  {"properties": {"indices": {"title": "Indices", "description": "The indices of the images that are relevant", "default": [], "type": "array", "items": {"type": "integer"}}}}
  ```
  ''';
  var response = await executeGptPrompt(prompt);
  var result =
      jsonDecode(response.replaceAll('json', '').replaceAll('```', ''));
  result['indices'] = result['indices'].map<int>((e) => e as int).toList();
  return result['indices'];
}

Future<SummaryResult> summarizePhotos(
    List<Tuple2<String, String>> images) async {
  var prompt =
      '''The user took a series of pictures from his POV, and generated a description for each photo, and wants to create a memory from them.

    For the title, use the main topic of the scenes.
    For the overview, condense the descriptions into a brief summary with the main topics discussed, make sure to capture the key points and important details.
    For the category, classify the scenes into one of the available categories.
        
    Photos Descriptions: ```${images.mapIndexed((i, e) => "${i + 1}. \"${e.item2}\"").join('\n')}```
    
    The output should be formatted as a JSON instance that conforms to the JSON schema below.

    As an example, for the schema {"properties": {"foo": {"title": "Foo", "description": "a list of strings", "type": "array", "items": {"type": "string"}}}, "required": ["foo"]}
    the object {"foo": ["bar", "baz"]} is a well-formatted instance of the schema. The object {"properties": {"foo": ["bar", "baz"]}} is not well-formatted.
    
    Here is the output schema:
    ```
    {"properties": {"title": {"title": "Title", "description": "A title/name for this conversation", "default": "", "type": "string"}, "overview": {"title": "Overview", "description": "An overview of the multiple scenes, highlighting the key details from it", "default": "", "type": "string"}, "category": {"description": "A category for this memory", "default": "other", "allOf": [{"\$ref": "#/definitions/CategoryEnum"}]}, "emoji": {"title": "Emoji", "description": "An emoji to represent the memory", "default": "\ud83e\udde0", "type": "string"}}, "definitions": {"CategoryEnum": {"title": "CategoryEnum", "description": "An enumeration.", "enum": ["personal", "education", "health", "finance", "legal", "phylosophy", "spiritual", "science", "entrepreneurship", "parenting", "romantic", "travel", "inspiration", "technology", "business", "social", "work", "other"], "type": "string"}}}
    ```
    '''
          .replaceAll('     ', '')
          .replaceAll('    ', '')
          .trim();
  debugPrint(prompt);
  var structuredResponse = extractJson(await executeGptPrompt(prompt));
  var structured = Structured.fromJson(jsonDecode(structuredResponse));
  return SummaryResult(structured, []);
}
