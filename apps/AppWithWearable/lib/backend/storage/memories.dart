// import 'dart:convert';
// import 'dart:math';

// import 'package:shared_preferences/shared_preferences.dart';

// //old memory structured class

// class MemoryStructured {
//   String title;
//   String overview;
//   List<String> actionItems;
//   List<String> pluginsResponse;
//   String emoji;
//   String category;
//   List<Map<String, dynamic>> events; // Add this line

//   MemoryStructured({
//     this.title = "",
//     this.overview = "",
//     required this.actionItems,
//     required this.pluginsResponse,
//     this.emoji = '',
//     this.category = '',
//     this.events = const [], // Add this line
//   });

//   factory MemoryStructured.fromJson(Map<String, dynamic> json) =>
//       MemoryStructured(
//         title: json['title'] ?? '',
//         overview: json['overview'] ?? '',
//         actionItems: List<String>.from(json['action_items'] ?? []),
//         pluginsResponse: List<String>.from(json['pluginsResponse'] ?? []),
//         category: json['category'] ?? '',
//         emoji: json['emoji'] ?? '',
//         events: List<Map<String, dynamic>>.from(
//             json['events'] ?? []), // Add this line
//       );

//   Map<String, dynamic> toJson() => {
//         'title': title,
//         'overview': overview,
//         'action_items': List<dynamic>.from(actionItems),
//         'pluginsResponse': List<dynamic>.from(pluginsResponse),
//         'emoji': emoji,
//         'category': category,
//         'events': events, // Add this line
//       };

//   getEmoji() {
//     try {
//       return utf8.decode(emoji.toString().codeUnits);
//     } catch (e) {
//       return ['🧠', '😎', '🧑‍💻', '🎂'][Random().nextInt(4)];
//     }
//   }

//   @override
//   String toString() {
//     var str = '';
//     str += '${getEmoji()} $title ($category)\n\nSummary: $overview\n\n';
//     if (actionItems.isNotEmpty) {
//       str += 'Action Items:\n';
//       for (var item in actionItems) {
//         str += '- $item\n';
//       }
//     }
//     return str;
//   }
// }

// class MemoryRecord {
//   String id;
//   DateTime createdAt;
//   String transcript;
//   String? recordingFilePath;
//   MemoryStructured structured;
//   bool discarded;

//   MemoryRecord({
//     required this.transcript,
//     required this.id,
//     required this.createdAt,
//     required this.structured,
//     this.recordingFilePath,
//     this.discarded = false,
//   });

//   factory MemoryRecord.fromJson(Map<String, dynamic> json) => MemoryRecord(
//         transcript: json['transcript'],
//         id: json['id'],
//         recordingFilePath: json['recording_file_path'],
//         createdAt: DateTime.parse(json['created_at']),
//         structured: MemoryStructured.fromJson(json['structured']),
//         discarded: json['discarded'] ?? false,
//       );

//   Map<String, dynamic> toJson() => {
//         'transcript': transcript,
//         'id': id,
//         'created_at': createdAt.toIso8601String(),
//         'structured': structured.toJson(),
//         'recording_audio_path': recordingFilePath,
//         'discarded': discarded,
//       };

//   static String memoriesToString(List<MemoryRecord> memories) => memories
//       .map((e) => '''
//       ${e.createdAt.toIso8601String().split('.')[0]}
//       Title: ${e.structured.title}
//       Summary: ${e.structured.overview}
//       ${e.structured.actionItems.isNotEmpty ? 'Action Items:' : ''}
//       ${e.structured.actionItems.map((item) => '  - $item').join('\n')}
//       ${e.structured.pluginsResponse.isNotEmpty ? 'Plugins Response:' : ''}
//       ${e.structured.pluginsResponse.map((response) => '  - $response').join('\n')}
//       Category: ${e.structured.category}
//       '''
//           .replaceAll('      ', '')
//           .trim())
//       .join('\n\n');
// }

// class MemoryStorage {
//   static const String _storageKey = '_memories';

//   static Future<List<MemoryRecord>> getAllMemories(
//       {includeDiscarded = false}) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String> allMemories = prefs.getStringList(_storageKey) ?? [];
//     List<MemoryRecord> memories = allMemories.reversed
//         .map((memory) => MemoryRecord.fromJson(jsonDecode(memory)))
//         .toList();
//     if (includeDiscarded)
//       return memories
//           .where((memory) => memory.transcript.split(' ').length > 10)
//           .toList();
//     return memories.where((memory) => !memory.discarded).toList();
//   }

//   static Future<List<MemoryRecord>> getAllMemoriesByIds(
//       List<String> memoriesId) async {
//     List<MemoryRecord> memories = await getAllMemories();
//     List<MemoryRecord> filtered = [];
//     for (MemoryRecord memory in memories) {
//       if (memoriesId.contains(memory.id)) {
//         filtered.add(memory);
//       }
//     }
//     return filtered;
//   }

//   static Future<void> updateWholeMemory(MemoryRecord newMemory) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String> allMemories = prefs.getStringList(_storageKey) ?? [];
//     int index = allMemories.indexWhere((memory) =>
//         MemoryRecord.fromJson(jsonDecode(memory)).id == newMemory.id);
//     if (index >= 0 && index < allMemories.length) {
//       allMemories[index] = jsonEncode(newMemory.toJson());
//       await prefs.setStringList(_storageKey, allMemories);
//     }
//   }
// }

//ne logic for adding events

import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

// class MemoryStructured {
//   bool forceProcess = false;
//   String title;
//   String overview;
//   List<String> actionItems;
//   List<String> pluginsResponse;
//   String emoji;
//   String category;
//   List<Event> events;

//   MemoryStructured({
//     this.title = "",
//     this.overview = "",
//     required this.actionItems,
//     required this.pluginsResponse,
//     this.emoji = '',
//     this.category = '',
//     this.events = const [],
//   });

//   factory MemoryStructured.fromJson(Map<String, dynamic> json) {
//     var structured = MemoryStructured(
//       title: json['title'] ?? '',
//       overview: json['overview'] ?? '',
//       actionItems: List<String>.from(json['action_items'] ?? []),
//       pluginsResponse: List<String>.from(json['pluginsResponse'] ?? []),
//       category: json['category'] ?? '',
//       emoji: json['emoji'] ?? '',
//     );

//     if (json['events'] != null) {
//       for (var event in json['events']) {
//         if (event.isEmpty) continue;
//         structured.events.add(Event.fromJson(event));
//       }
//     }

//     return structured;
//   }

//   Map<String, dynamic> toJson() => {
//         'title': title,
//         'overview': overview,
//         'action_items': List<dynamic>.from(actionItems),
//         'pluginsResponse': List<dynamic>.from(pluginsResponse),
//         'emoji': emoji,
//         'category': category,
//         'events': events.map((event) => event.toJson()).toList(),
//       };

//   getEmoji() {
//     try {
//       return utf8.decode(emoji.toString().codeUnits);
//     } catch (e) {
//       return ['🧠', '😎', '🧑‍💻', '🎂'][Random().nextInt(4)];
//     }
//   }

//   @override
//   String toString() {
//     var str = '';
//     str += '${getEmoji()} $title ($category)\n\nSummary: $overview\n\n';
//     if (actionItems.isNotEmpty) {
//       str += 'Action Items:\n';
//       for (var item in actionItems) {
//         str += '- $item\n';
//       }
//     }
//     if (events.isNotEmpty) {
//       str += 'Events:\n';
//       for (var event in events) {
//         str += '- ${event.title} at ${event.startsAt}\n';
//       }
//     }
//     return str;
//   }
// }

// class Event {
//   String title;
//   DateTime startsAt;
//   int duration;
//   String description;
//   bool created;

//   Event(this.title, this.startsAt, this.duration,
//       {this.description = '', this.created = false});

//   factory Event.fromJson(Map<String, dynamic> json) {
//     return Event(
//       json['title'],
//       DateTime.parse(json['startsAt']),
//       json['duration'],
//       description: json['description'] ?? '',
//       created: json['created'] ?? false,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'title': title,
//         'startsAt': startsAt.toIso8601String(),
//         'duration': duration,
//         'description': description,
//         'created': created,
//       };
// }

class MemoryStructured {
  bool forceProcess = false;
  String title;
  String overview;
  List<String> actionItems;
  List<String> pluginsResponse;
  String emoji;
  String category;
  List<Event> events;

  MemoryStructured({
    this.title = "",
    this.overview = "",
    required List<String> actionItems,
    required List<String> pluginsResponse,
    this.emoji = '',
    this.category = '',
    List<Event> events = const [],
  })  : actionItems = List<String>.from(actionItems),
        pluginsResponse = List<String>.from(pluginsResponse),
        events = List<Event>.from(events);

  factory MemoryStructured.fromJson(Map<String, dynamic> json) {
    var structured = MemoryStructured(
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      actionItems: List<String>.from(json['action_items'] ?? []),
      pluginsResponse: List<String>.from(json['pluginsResponse'] ?? []),
      category: json['category'] ?? '',
      emoji: json['emoji'] ?? '',
    );

    if (json['events'] != null) {
      structured.events = List<Event>.from(
          json['events'].map((event) => Event.fromJson(event)).toList());
    }

    return structured;
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'overview': overview,
        'action_items': List<dynamic>.from(actionItems),
        'pluginsResponse': List<dynamic>.from(pluginsResponse),
        'emoji': emoji,
        'category': category,
        'events': events.map((event) => event.toJson()).toList(),
      };

  getEmoji() {
    try {
      return utf8.decode(emoji.toString().codeUnits);
    } catch (e) {
      return ['🧠', '😎', '🧑‍💻', '🎂'][Random().nextInt(4)];
    }
  }

  @override
  String toString() {
    var str = '';
    str += '${getEmoji()} $title ($category)\n\nSummary: $overview\n\n';
    if (actionItems.isNotEmpty) {
      str += 'Action Items:\n';
      for (var item in actionItems) {
        str += '- $item\n';
      }
    }
    if (events.isNotEmpty) {
      str += 'Events:\n';
      for (var event in events) {
        str += '- ${event.title} at ${event.startsAt}\n';
      }
    }
    return str;
  }
}

class Event {
  String title;
  DateTime startsAt;
  int duration;
  String description;
  bool created;

  Event(this.title, this.startsAt, this.duration,
      {this.description = '', this.created = false});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      json['title'],
      DateTime.parse(json['startsAt']),
      json['duration'],
      description: json['description'] ?? '',
      created: json['created'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'startsAt': startsAt.toIso8601String(),
        'duration': duration,
        'description': description,
        'created': created,
      };
}

class MemoryRecord {
  String id;
  DateTime createdAt;
  String transcript;
  String? recordingFilePath;
  MemoryStructured structured;
  bool discarded;

  MemoryRecord({
    required this.transcript,
    required this.id,
    required this.createdAt,
    required this.structured,
    this.recordingFilePath,
    this.discarded = false,
  });

  factory MemoryRecord.fromJson(Map<String, dynamic> json) => MemoryRecord(
        transcript: json['transcript'],
        id: json['id'],
        recordingFilePath: json['recording_file_path'],
        createdAt: DateTime.parse(json['created_at']),
        structured: MemoryStructured.fromJson(json['structured']),
        discarded: json['discarded'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'transcript': transcript,
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'structured': structured.toJson(),
        'recording_audio_path': recordingFilePath,
        'discarded': discarded,
      };

  static String memoriesToString(List<MemoryRecord> memories) => memories
      .map((e) => '''
      ${e.createdAt.toIso8601String().split('.')[0]}
      Title: ${e.structured.title}
      Summary: ${e.structured.overview}
      ${e.structured.actionItems.isNotEmpty ? 'Action Items:' : ''}
      ${e.structured.actionItems.map((item) => '  - $item').join('\n')}
      ${e.structured.pluginsResponse.isNotEmpty ? 'Plugins Response:' : ''}
      ${e.structured.pluginsResponse.map((response) => '  - $response').join('\n')}
      Category: ${e.structured.category}
      ${e.structured.events.isNotEmpty ? 'Events:' : ''}
      ${e.structured.events.map((event) => '  - ${event.title} at ${event.startsAt}').join('\n')}
      '''
          .replaceAll('      ', '')
          .trim())
      .join('\n\n');
}

class MemoryStorage {
  static const String _storageKey = '_memories';

  static Future<List<MemoryRecord>> getAllMemories(
      {includeDiscarded = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> allMemories = prefs.getStringList(_storageKey) ?? [];
    List<MemoryRecord> memories = allMemories.reversed
        .map((memory) => MemoryRecord.fromJson(jsonDecode(memory)))
        .toList();
    if (includeDiscarded)
      return memories
          .where((memory) => memory.transcript.split(' ').length > 10)
          .toList();
    return memories.where((memory) => !memory.discarded).toList();
  }

  static Future<List<MemoryRecord>> getAllMemoriesByIds(
      List<String> memoriesId) async {
    List<MemoryRecord> memories = await getAllMemories();
    List<MemoryRecord> filtered = [];
    for (MemoryRecord memory in memories) {
      if (memoriesId.contains(memory.id)) {
        filtered.add(memory);
      }
    }
    return filtered;
  }

  static Future<void> updateWholeMemory(MemoryRecord newMemory) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> allMemories = prefs.getStringList(_storageKey) ?? [];
    int index = allMemories.indexWhere((memory) =>
        MemoryRecord.fromJson(jsonDecode(memory)).id == newMemory.id);
    if (index >= 0 && index < allMemories.length) {
      allMemories[index] = jsonEncode(newMemory.toJson());
      await prefs.setStringList(_storageKey, allMemories);
    }
  }
}
