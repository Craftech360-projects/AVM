// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:friend_private/backend/api_requests/api/llm.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/backend/database/prompt_provider.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/plugin.dart';
import 'package:friend_private/utils/other/string_utils.dart';
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
  print('is prompt saved $isPromptSaved');
  if (isPromptSaved) {
    final prompt = PromptProvider().getPrompts().first;
    print('prompt fetched from object box ${prompt.toString()}');
  }
  print('custom prompt ${customPromptDetails.toString()}');
  //  if (customPromptDetails != null) {
  //   final savedPrompt = SharedPreferencesUtil().getSelectedPrompt('prompt');
  //   final savedTitle = SharedPreferencesUtil().getSelectedPrompt('title');
  //   final savedOverview = SharedPreferencesUtil().getSelectedPrompt('overview');
  //   final savedActionItems = SharedPreferencesUtil().getSelectedPrompt('actionItems');
  //   final savedCategory = SharedPreferencesUtil().getSelectedPrompt('category');
  //   final savedCalendar = SharedPreferencesUtil().getSelectedPrompt('calendar');

  //   customPromptDetails = CustomPrompt(
  //     prompt: savedPrompt,
  //     title: savedTitle,
  //     overview: savedOverview,
  //     actionItems: savedActionItems,
  //     category: savedCategory,
  //     calendar: savedCalendar,
  //   );
  // }

  debugPrint('summarizeMemory transcript length: ${transcript.length}');
  if (transcript.isEmpty || transcript.split(' ').length < 7) {
    return SummaryResult(Structured('', ''), []);
  }
  if (transcript.split(' ').length > 100) {
    // try lower count?
    forceProcess = true;
  }

  // try later with temperature 0
  // NOTE: PROMPT IS VERY DELICATE, IT CAN DISCARD EVERYTHING IF NOT HANDLED PROPERLY
  // The purpose for structuring this memory is to remember important conversations, decisions, and action items. If there's nothing like that in the transcript, output an empty title.
  var prompt = '''
Summarize the following conversation transcript. The conversation language is ${SharedPreferencesUtil().recordingsLanguage}. Respond in English.

${forceProcess ? "" : "If the conversation does not contain significant insights or action items, output an empty title."}

**Key Instructions**: 
- Provide a detailed summary of the conversation, capturing the most important discussion points, insights, decisions, and commitments.
- Ensure the summary is comprehensive and does not omit critical details.
- Summaries should not be too brief. The overview must contain at least 100 words, and key highlights should provide enough context to understand the depth of the discussion.

Provide the following:
1. **Title**: ${customPromptDetails?.title ?? 'The main topic or most important theme of the conversation.'}
2. **Overview**: ${customPromptDetails?.overview ?? 'A detailed summary (minimum 100 words) of the key points and most significant details discussed, including decisions and major insights.'}
3. **Action Items**: ${customPromptDetails?.actionItems ?? 'A detailed list of tasks or commitments, including the context or reason behind each task, along with who is responsible for them and any deadlines.'}
4. **Category**: ${customPromptDetails?.category ?? 'Classify the conversation under up to 3 categories (personal, education, health, finance, legal, philosophy, spiritual, science, entrepreneurship, parenting, romantic, travel, inspiration, technology, business, social, work, other).'}
5. **Emoji**: A single emoji that represents the conversation theme.
6. **Calendar Events**: ${customPromptDetails?.calendar ?? 'Any specific events mentioned during the conversation. Include the title, description, start time, and duration.'}

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
  "category":[{"string"}] ,
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
  print(">>>>>>, $prompt");
  var structuredResponse =
      extractJson(await executeGptPrompt(prompt, ignoreCache: ignoreCache));

  debugPrint("got response, $structuredResponse");
  try {
    //here need tostructured unt his format
//Title:
//  Overview:
//  Action Items: []
//  Category: other
//  Emoji:
//  Events: []
//  Plugins Response:
    var structured = Structured.fromJson(await jsonDecode(structuredResponse));
    debugPrint("structured, $structured");

    var pluginsResponse = await executePlugins(transcript);
    print("$pluginsResponse");
    if (structured.title.isEmpty) return SummaryResult(structured, []);

    //var pluginsResponse = await executePlugins(transcript);
    return SummaryResult(structured, pluginsResponse);
  } catch (e) {
    debugPrint("error, $e");
    return SummaryResult(Structured('', ''), []);
  }
}

Future<List<Tuple2<Plugin, String>>> executePlugins(String transcript) async {
  print("executing pluginssss .....$transcript");
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
        
        Note: It is possible that the conversation you are given, has nothing to do with your task, \
        in that case, output an empty string. (For example, you are given a business conversation, but your task is medical analysis)
        
        Conversation: ```${transcript.trim()}```,
       
        Output your response in plain text, without markdown.
        Make sure to be concise and clear.
        '''
            .replaceAll('     ', '')
            .replaceAll('    ', '')
            .trim());

        print("plugin response, $response");

        return Tuple2(
            plugin, response.replaceAll('```', '').replaceAll('""', '').trim());
      } catch (e) {
        // CrashReporting.reportHandledCrash(e, stacktrace,
        //     level: NonFatalExceptionLevel.critical,
        //     userAttributes: {
        //       'plugin': plugin.id,
        //       'plugins_count': pluginsEnabled.length.toString(),
        //       'transcript_length': transcript.length.toString(),
        //     });
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
    // CrashReporting.reportHandledCrash(e, stacktrace,
    //     level: NonFatalExceptionLevel.critical,
    //     userAttributes: {
    //       'plugins_count': pluginsEnabled.length.toString(),
    //       'transcript_length': transcript.length.toString(),
    //     });
    return [];
  }
}

Future<String> triggerTestMemoryPrompt(String prompt, String transcript) async {
  return await executeGptPrompt('''
        Your are an AI with the following characteristics:
        Task: $prompt
        
        Note: It is possible that the conversation you are given, has nothing to do with your task, \
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
  Please analyze the following transcript and identify the distinct topics discussed within the conversation. \ 
  For each identified topic, provide a detailed summary that captures the key points and important details. \
  Ensure that each summary is comprehensive yet concise, reflecting the main ideas and any relevant subtopics. \
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
  Please analyze the following transcript and generate a friendly and engaging reply as if you were a close friend. \
  The reply should be supportive, empathetic, and conversational. Make sure to address any concerns or questions raised in the transcript, \
  and provide encouragement or advice where appropriate. Keep the tone casual and friendly.
  
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
  Hey there! It sounds like you have a solid plan for the upcoming project. Getting the prototype ready by the end of next month is a great goal. \
  The budget estimate of \$50,000 seems reasonable, and it's smart to include development, testing, and marketing costs. \
  I totally agree that considering potential risks and having a risk management plan is crucial. Keep up the great work, and don't hesitate to reach out if you need any help!
  
  Respond in a JSON format with the following structure:
  {
    "reply": "Desired Output"
  }
  
  Transcript:
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
      'There were no memories today, don\'t forget to wear your AVM tomorrow 😁';
  if (memories.isEmpty) return msg;
  if (memories.where((m) => !m.discarded).length <= 1) return msg;
  var str = SharedPreferencesUtil().givenName.isEmpty
      ? 'the user'
      : SharedPreferencesUtil().givenName;
  var prompt = '''
  The following are a list of $str\'s memories from today, with the transcripts with its respective structuring, that $str had during his day.
  $str wants to get a summary of the key action items he has to take based on his today's memories.

  Remember $str is busy so this has to be very efficient and concise.
  Respond in at most 50 words.
  
  Output your response in plain text, without markdown.
  ```
  ${Memory.memoriesToString(memories, includeTranscript: true)}
  ```
  ''';
  debugPrint(prompt);
  var result = await executeGptPrompt(prompt);
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
  print("determine>>>>>1 $cleanedResponse");

  try {
    print("determine>>>>>2");
    var data = jsonDecode(cleanedResponse);
    print("determine>>>>>3");
    debugPrint(">>>>>>>clean data: $data");

    List<String> topics =
        data['topics'].map<String>((e) => e.toString()).toList();
    List<String> datesRange =
        data['dates_range'].map<String>((e) => e.toString()).toList();
    List<DateTime> dates = datesRange.map((e) => DateTime.parse(e)).toList();
    debugPrint('topics: $topics, dates: $dates');
    return Tuple2<List<String>, List<DateTime>>(topics, dates);
  } catch (e) {
    // CrashReporting.reportHandledCrash(e, StackTrace.current,
    //     level: NonFatalExceptionLevel.critical,
    //     userAttributes: {
    //       'response': cleanedResponse,
    //       'message_length': message.length.toString(),
    //       'message_words': message.split(' ').length.toString(),
    //     });
    debugPrint('Error determining requires context: $e');
    return null;
  }
}

//this below will work with chatgpt
// Future<Tuple2<List<String>, List<DateTime>>?> determineRequiresContext(
//     List<Message> messages) async {
//   String message = '''
//         Based on the current conversation an AI and a User are having, determine if the AI requires context outside the conversation to respond to the user's message.
//         More context could mean, user stored old conversations, notes, or information that seems very user-specific.

//         - First determine if the conversation requires context, in the field "requires_context".
//         - Context could be 2 different things:
//           - A list of topics (each topic being 1 or 2 words, e.g. "Startups" "Funding" "Business Meeting" "Artificial Intelligence") that are going to be used to retrieve more context, in the field "topics". Leave an empty list if not context is needed.
//           - A dates range, if the context is time-based, in the field "dates_range". Leave an empty list if not context is needed. FYI if the user says today, today is ${DateTime.now().toIso8601String()}.

//         Conversation:
//         ${Message.getMessagesAsString(messages)}

//         The output should be formatted as a JSON instance that conforms to the JSON schema below.

//         As an example, for the schema {"properties": {"foo": {"title": "Foo", "description": "a list of strings", "type": "array", "items": {"type": "string"}}}, "required": ["foo"]}
//         the object {"foo": ["bar", "baz"]} is a well-formatted instance of the schema. The object {"properties": {"foo": ["bar", "baz"]}} is not well-formatted.

//         Here is the output schema:
//         ```
//         {"properties": {"requires_context": {"title": "Requires Context", "description": "Based on the conversation, this tells if context is needed to respond", "default": false, "type": "string"}, "topics": {"title": "Topics", "description": "If context is required, the topics to retrieve context from", "default": [], "type": "array", "items": {"type": "string"}}, "dates_range": {"title": "Dates Range", "description": "The dates range to retrieve context from", "default": [], "type": "array", "minItems": 2, "maxItems": 2, "items": [{"type": "string", "format": "date-time"}, {"type": "string", "format": "date-time"}]}}}
//         ```
//         '''
//       .replaceAll('        ', '');
//   debugPrint('determineRequiresContext message: $message');

//   var response = await executeGptPrompt(message);

//   debugPrint('determineRequiresContext response: $response');
//   var cleanedResponse =
//       response.toString().replaceAll('```', '').replaceAll('json', '').trim();
//   print("determine>>>>>1 $cleanedResponse");
//   try {
//     print("determine>>>>>2");
//     var data = jsonDecode(cleanedResponse);
//     print("determine>>>>>3");
//     debugPrint(">>>>>>>clean data: $data");

//     debugPrint(data.toString());
//     print("determine>>>>>4");
//     List<String> topics =
//         data['topics'].map<String>((e) => e.toString()).toList();
//     List<String> datesRange =
//         data['dates_range'].map<String>((e) => e.toString()).toList();
//     List<DateTime> dates = datesRange.map((e) => DateTime.parse(e)).toList();
//     debugPrint('topics: $topics, dates: $dates');
//     return Tuple2<List<String>, List<DateTime>>(topics, dates);
//   } catch (e) {
//     CrashReporting.reportHandledCrash(e, StackTrace.current,
//         level: NonFatalExceptionLevel.critical,
//         userAttributes: {
//           'response': cleanedResponse,
//           'message_length': message.length.toString(),
//           'message_words': message.split(' ').length.toString(),
//         });
//     debugPrint('Error determining requires context: $e');
//     return null;
//   }
// }

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
// Print() git push --set-upstream origin --force chatfix

Future<String> getInitialPluginPrompt(Plugin? plugin) async {
  if (plugin == null) {
    return '''
        Your are an AI with the following characteristics:
        Name: AVM, 
        Personality/Description: A friendly and helpful AI assistant that aims to make your life easier and more enjoyable.
        Task: Provide assistance, answer questions, and engage in meaningful conversations.
        
        Send an initial message to start the conversation, make sure this message reflects your personality, \
        humor, and characteristics.
       
        Output your response in plain text, without markdown, and it should be below 20 words.
    ''';
  }
  return '''
        Your are an AI with the following characteristics:
        Name: ${plugin.name}, 
        Personality/Description: ${plugin.chatPrompt},
        Task: ${plugin.memoryPrompt}
        
        Send an initial message to start the conversation, make sure this message reflects your personality, \
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
  print(result['indices']);
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
