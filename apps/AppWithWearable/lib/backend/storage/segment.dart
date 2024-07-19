import 'dart:convert';

import 'package:AVMe/backend/preferences.dart';

class TranscriptSegment {
  String text;
  String? speaker;
  late int speakerId;
  bool isUser;
  double start;
  double end;

  TranscriptSegment({
    required this.text,
    required this.speaker,
    required this.isUser,
    required this.start,
    required this.end,
  }) {
    speakerId = speaker != null ? int.parse(speaker!.split('_')[1]) : 0;
  }

  @override
  String toString() {
    return 'TranscriptSegment: {text: $text, speaker: $speaker, isUser: $isUser, start: $start, end: $end}';
  }

  // Factory constructor to create a new Message instance from a map
  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      text: json['text'] as String,
      speaker: (json['speaker'] ?? 'SPEAKER_00') as String,
      isUser: json['is_user'] as bool,
      start: json['start'] as double,
      end: json['end'] as double,
    );
  }

  // Method to convert a Message instance into a map
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'speaker': speaker,
      'speaker_id': speakerId,
      'is_user': isUser,
      'start': start,
      'end': end,
    };
  }

  static List<TranscriptSegment> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => TranscriptSegment.fromJson(e)).toList();
  }

  String getTimestampString() {
    var start = Duration(seconds: this.start.toInt());
    var end = Duration(seconds: this.end.toInt());
    return '${start.inHours.toString().padLeft(2, '0')}:${(start.inMinutes % 60).toString().padLeft(2, '0')}:${(start.inSeconds % 60).toString().padLeft(2, '0')} - ${end.inHours.toString().padLeft(2, '0')}:${(end.inMinutes % 60).toString().padLeft(2, '0')}:${(end.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  static String segmentsAsString(
    List<TranscriptSegment> segments, {
    bool includeTimestamps = false,
  }) {
    String transcript = '';
    var userName = SharedPreferencesUtil().givenName;
    includeTimestamps =
        includeTimestamps && TranscriptSegment.canDisplaySeconds(segments);
    for (var segment in segments) {
      // TODO: maybe store TranscriptSegment directly as utf8 decoded
      var segmentText = utf8.decode(segment.text.trim().codeUnits);
      var timestampStr =
          includeTimestamps ? '[${segment.getTimestampString()}]' : '';
      if (segment.isUser) {
        transcript +=
            '$timestampStr ${userName.isEmpty ? 'User' : userName}: $segmentText ';
      } else {
        transcript +=
            '$timestampStr Speaker ${segment.speakerId}: $segmentText ';
      }
      transcript += '\n\n';
    }
    return transcript.trim();
  }

  static bool canDisplaySeconds(List<TranscriptSegment> segments) {
    for (var i = 0; i < segments.length; i++) {
      for (var j = i + 1; j < segments.length; j++) {
        if (segments[i].start > segments[j].end ||
            segments[i].end > segments[j].start) {
          return false;
        }
      }
    }
    return true;
  }
}
