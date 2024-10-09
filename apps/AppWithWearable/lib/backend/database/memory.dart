// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:friend_private/backend/database/geolocation.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:objectbox/objectbox.dart';

enum MemoryType { audio, image }

@Entity()
class Memory {
  @Id()
  int id = 0;

  @Index()
  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime? startedAt;

  @Property(type: PropertyType.date)
  DateTime? finishedAt;

  String transcript;
  @Property(type: PropertyType.byteVector)
  Uint8List? memoryImg;

  final transcriptSegments = ToMany<TranscriptSegment>();
  final photos = ToMany<MemoryPhoto>();

  String? recordingFilePath;

  final structured = ToOne<Structured>();

  @Backlink('memory')
  final pluginsResponse = ToMany<PluginResponse>();

  @Index()
  bool discarded;

  final geolocation = ToOne<Geolocation>();

  Memory(
    this.createdAt,
    this.transcript,
    this.memoryImg,
    this.discarded, {
    this.id = 0,
    this.recordingFilePath,
    this.startedAt,
    this.finishedAt,
  });

  void setStructured(Structured structured) {
    this.structured.target = structured;
    if (this.geolocation.target != null) {
      structured.setGeolocation(this.geolocation.target);
    }
  }

  MemoryType get type =>
      transcript.isNotEmpty ? MemoryType.audio : MemoryType.image;

  static String memoriesToString(List<Memory> memories,
          {bool includeTranscript = false}) =>
      memories
          .map((e) => '''
      ${e.createdAt.toIso8601String().split('.')[0]}
      Title: ${e.structured.target!.title}
      Summary: ${e.structured.target!.overview}
      ${e.structured.target!.actionItems.isNotEmpty ? 'Action Items:' : ''}
      ${e.structured.target!.actionItems.map((item) => '  - ${item.description}').join('\n')}
      Category: ${e.structured.target!.category}
      ${includeTranscript ? 'Transcript:\n${e.transcript}' : ''}
      '''
              .replaceAll('      ', '')
              .trim())
          .join('\n\n');

  static Memory fromJson(Map<String, dynamic> json) {
    var memory = Memory(
      DateTime.parse(json['createdAt']),
      json['transcript'],
       json['memoryImg'] != null ? Uint8List.fromList(List<int>.from(json['memoryImg'])) : null,
      json['discarded'],
      recordingFilePath: json['recordingFilePath'],
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      finishedAt: json['finishedAt'] != null
          ? DateTime.parse(json['finishedAt'])
          : null,
    );
    memory.structured.target = Structured.fromJson(json['structured']);
    memory.structured.target = Structured.fromJson(json['structured']);
    if (json['structured'] != null) {
      memory.structured.target = Structured.fromJson(json['structured']);
    }
    
    if (json['geolocation'] != null) {
      memory.geolocation.target = Geolocation.fromJson(json['geolocation']);
      if (memory.structured.target != null) {
        memory.structured.target!.setGeolocation(memory.geolocation.target);
      }
    }

    if (json['pluginsResponse'] != null) {
      for (dynamic response in json['pluginsResponse']) {
        if (response.isEmpty) continue;
        if (response is String) {
          memory.pluginsResponse.add(PluginResponse(response));
        } else {
          memory.pluginsResponse.add(PluginResponse.fromJson(response));
        }
      }
    }

    if (json['transcriptSegments'] != null) {
      for (dynamic segment in json['transcriptSegments']) {
        if (segment.isEmpty) continue;
        memory.transcriptSegments.add(TranscriptSegment.fromJson(segment));
      }
    }

    if (json['photos'] != null) {
      for (dynamic photo in json['photos']) {
        if (photo.isEmpty) continue;
        memory.photos.add(MemoryPhoto.fromJson(photo));
      }
    }

    return memory;
  }

  String getTranscript({int? maxCount, bool generate = false}) {
    try {
      var transcript = generate && transcriptSegments.isNotEmpty
          ? TranscriptSegment.segmentsAsString(transcriptSegments,
              includeTimestamps: true)
          : this.transcript;
      var decoded = utf8.decode(transcript.codeUnits);
      if (maxCount != null) {
        return decoded.substring(0, min(maxCount, decoded.length));
      }
      return decoded;
    } catch (e) {
      return transcript;
    }
  }

  toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'memoryImg': memoryImg ,
      // 'memoryImg': memoryImg != null ? 'True' : 'False',
      'finishedAt': finishedAt?.toIso8601String(),
      'transcript': transcript,
      'recordingFilePath': recordingFilePath,
      'structured': structured.target!.toJson(),
      'geolocation': geolocation.target != null
          ? geolocation.target!.toJson()
          : null, // Add this line
      'pluginsResponse': pluginsResponse
          .map<Map<String, String?>>((response) => response.toJson())
          .toList(),
      'discarded': discarded,
      'transcriptSegments':
          transcriptSegments.map((segment) => segment.toJson()).toList(),
      'photos': photos.map((photo) => photo.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Memory(id: $id, createdAt: $createdAt, startedAt: $startedAt, finishedAt: $finishedAt, transcript: $transcript, memoryImg: $memoryImg, recordingFilePath: $recordingFilePath, discarded: $discarded)';
  }
}

@Entity()
class Structured {
  @Id()
  int id = 0;

  String title;
  String overview;
  String emoji;
  List<String> category = [];

  @Backlink('structured')
  final actionItems = ToMany<ActionItem>();

  @Backlink('structured')
  final events = ToMany<Event>();
  final geolocation = ToOne<Geolocation>(); // Add this line
  String? get placeName => geolocation.target?.placeName;

  Structured(this.title, this.overview,
      {this.id = 0, this.emoji = '', this.category = const []});

  getEmoji() {
    try {
      if (emoji.isNotEmpty) return utf8.decode(emoji.toString().codeUnits);
      return ['🧠', '😎', '🧑‍💻', '🚀'][Random().nextInt(4)];
    } catch (e) {
      return ['🧠', '😎', '🧑‍💻', '🎂'][Random().nextInt(4)];
    }
  }

  void setGeolocation(Geolocation? location) {
    if (location != null) {
      geolocation.target = location;
    }
  }

  static Structured fromJson(Map<String, dynamic> json) {
    var structured = Structured(
      json['title'] ?? '',
      json['overview'] ?? '',
      emoji: json['emoji'] ?? '',
      category:
          json['category'] != null ? List<String>.from(json['category']) : [],
    );
    if (json['geolocation'] != null) {
      structured.geolocation.target = Geolocation.fromJson(json['geolocation']);
    }

    var aItems = json['action_items'] ?? [];
    if (aItems is List) {
      for (var item in aItems) {
        if (item is Map<String, dynamic>) {
          structured.actionItems.add(ActionItem(item['task'] ?? ''));
        } else if (item is String && item.isNotEmpty) {
          structured.actionItems.add(ActionItem(item));
        }
      }
    }

    var events = json['events'] ?? [];
    if (events is List) {
      for (var event in events) {
        if (event is Map<String, dynamic>) {
          try {
            structured.events.add(Event(
              event['title'] ?? '',
              DateTime.parse(event['start_time'] ?? '').toUtc(),
              event['duration'] ?? 30,
              description: event['description'] ?? '',
              created: false,
            ));
          } catch (e) {
            print('Error parsing event: $e');
            // Skip this event if there's an error
          }
        }
      }
    }
    return structured;
  }

  @override
  String toString() {
    return 'Structured(id: $id, title: $title, overview: $overview, emoji: $emoji, category: $category)';
  }

  toJson() {
    return {
      'title': title,
      'overview': overview,
      'emoji': emoji,
      'category': category,
      'actionItems': actionItems.map((item) => item.description).toList(),
      'events': events.map((event) => event.toJson()).toList(),
      'geolocation': geolocation.target?.toJson(), // Add this line
      'placeName': placeName,
    };
  }
}

@Entity()
class ActionItem {
  @Id()
  int id = 0;

  String description;
  bool completed = false;
  final structured = ToOne<Structured>();

  ActionItem(this.description, {this.id = 0, this.completed = false});
}

@Entity()
class PluginResponse {
  @Id()
  int id = 0;

  String? pluginId;
  String content;

  final memory = ToOne<Memory>();

  PluginResponse(this.content, {this.id = 0, this.pluginId});

  toJson() {
    return {
      'pluginId': pluginId,
      'content': content,
    };
  }

  factory PluginResponse.fromJson(Map<String, dynamic> json) {
    return PluginResponse(json['content'], pluginId: json['pluginId']);
  }
}

@Entity()
class Event {
  @Id()
  int id = 0;

  String title;
  DateTime startsAt;
  int duration;

  String description;
  bool created = false;

  final structured = ToOne<Structured>();

  Event(this.title, this.startsAt, this.duration,
      {this.description = '', this.created = false, this.id = 0});

  toJson() {
    return {
      'title': title,
      'startsAt': startsAt.toIso8601String(),
      'duration': duration,
      'description': description,
      'created': created,
    };
  }
}

@Entity()
class MemoryPhoto {
  @Id()
  int id = 0;

  String base64;
  String description;
  final memory = ToOne<Memory>();

  MemoryPhoto(this.base64, this.description, {this.id = 0});

  factory MemoryPhoto.fromJson(Map<String, dynamic> json) {
    return MemoryPhoto(json['base64'], json['description']);
  }

  toJson() {
    return {
      'base64': base64,
      'description': description,
    };
  }
}
