import 'package:flutter/material.dart';
import 'package:friend_private/backend/api_requests/api/pinecone.dart';
import 'package:friend_private/backend/api_requests/api/prompt.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/database/message_provider.dart';
import 'package:instabug_flutter/instabug_flutter.dart';
import 'package:tuple/tuple.dart';

// Future<List<dynamic>> retrieveRAGContext(String message,
//     {String? prevMessagesPluginId}) async {
//   var prevMessages = await MessageProvider()
//       .retrieveMostRecentMessages(limit: 10, pluginId: prevMessagesPluginId);
//   Tuple2<List<String>, List<DateTime>>? ragContext =
//       await determineRequiresContext(prevMessages);

//   if (ragContext == null ||
//       (ragContext.item1.isEmpty && ragContext.item2.isEmpty)) {
//     return ['', []];
//   }

//   List<String> topics = ragContext.item1;
//   List<DateTime> datesRange = ragContext.item2;

//   var startTimestamp = datesRange.isNotEmpty ? datesRange[0] : null;
//   var endTimestamp = datesRange.isNotEmpty ? datesRange[1] : null;

//   // Replace Pinecone calls with ObjectBox queries
//   List<Memory> memories =
//       await _retrieveMemoriesByTopic(topics, startTimestamp, endTimestamp);

//   if (topics.isEmpty && datesRange.isNotEmpty) {
//     memories = MemoryProvider()
//         .retrieveMemoriesWithinDates(datesRange[0], datesRange[1]);
//   }

//   return [Memory.memoriesToString(memories), memories];
// }

// Future<List<List<String>>> _retrieveMemoriesByTopic(
//   List<String> topics,
//   int? startTimestamp,
//   int? endTimestamp,
//   String message,
// ) {
//   return Future.wait(topics.map((topic) async {
//     try {
//       List<double> vectorizedMessage = await getEmbeddingsFromInput(topic);
//       List<String> memoriesId = await queryPineconeVectors(
//         vectorizedMessage,
//         startTimestamp: startTimestamp,
//         endTimestamp: endTimestamp,
//         count: 5,
//       );
//       debugPrint(
//           'queryPineconeVectors memories retrieved for topic $topic: ${memoriesId.length}');
//       return memoriesId;
//     } catch (e, stacktrace) {
//       CrashReporting.reportHandledCrash(e, stacktrace,
//           level: NonFatalExceptionLevel.error,
//           userAttributes: {
//             'message_length': message.length.toString(),
//             'topics_count': topics.length.toString(),
//             // 'topic_failed': topic,
//             // TODO: would it be okay to the vectorizedMessage instead? so we can replicate without knowing the message
//           });
//       return [];
//     }
//   }));
// }

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/database/message_provider.dart';
import 'package:tuple/tuple.dart';

Future<List<dynamic>> retrieveRAGContext(String message,
    {String? prevMessagesPluginId}) async {
  // Retrieve previous messages for context
  var prevMessages = await MessageProvider()
      .retrieveMostRecentMessages(limit: 10, pluginId: prevMessagesPluginId);

  // Determine RAG context from previous messages (topics and dates)
  Tuple2<List<String>, List<DateTime>>? ragContext =
      await determineRequiresContext(prevMessages);

  if (ragContext == null ||
      (ragContext.item1.isEmpty && ragContext.item2.isEmpty)) {
    return ['', []];
  }

  List<String> topics = ragContext.item1;
  List<DateTime> datesRange = ragContext.item2;

  var startTimestamp = datesRange.isNotEmpty ? datesRange[0] : null;
  var endTimestamp = datesRange.isNotEmpty ? datesRange[1] : null;

  // Use ObjectBox instead of Pinecone for memory retrieval
  List<Memory> memories =
      await _retrieveMemoriesByTopic(topics, startTimestamp, endTimestamp);

  // If no topics but we have date range, retrieve memories within the date range
  if (topics.isEmpty && datesRange.isNotEmpty) {
    memories = MemoryProvider()
        .retrieveMemoriesWithinDates(datesRange[0], datesRange[1]);
  }

  return [Memory.memoriesToString(memories), memories];
}

Future<List<Memory>> _retrieveMemoriesByTopic(
  List<String> topics,
  DateTime? startTimestamp,
  DateTime? endTimestamp,
) async {
  List<Memory> memories = [];

  // If topics are provided, search for them in the structured data (category, overview, etc.)
  if (topics.isNotEmpty) {
    var allMemories = MemoryProvider().getMemories();
    memories = allMemories.where((memory) {
      return topics.any((topic) =>
          memory.structured.target!.category.contains(topic) ||
          memory.structured.target!.overview.contains(topic));
    }).toList();
  }

  // Filter by date range if provided
  if (startTimestamp != null && endTimestamp != null) {
    memories = MemoryProvider()
        .retrieveMemoriesWithinDates(startTimestamp, endTimestamp);
  }

  return memories;
}