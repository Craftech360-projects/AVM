import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:capsaul/backend/api_requests/api/shared.dart';
import 'package:capsaul/backend/database/memory.dart';
import 'package:capsaul/backend/database/transcript_segment.dart';
import 'package:capsaul/backend/preferences.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:http/http.dart' as http;

Future<List<TranscriptSegment>> deepgramTranscribe(File file) async {
  // why there seems to be no punctuation
  Deepgram deepgram = Deepgram(getDeepgramApiKeyForUsage(), baseQueryParams: {
    'model': 'nova-2-general',
    'detect_language': false,
    'language': SharedPreferencesUtil().recordingsLanguage,
    'filler_words': false,
    'punctuate': true,
    'diarize': true,
    'smart_format': true,
    'multichannel': false
    // 'detect_topics': true,
    // 'topics': true,
    // 'intents': true,
    // 'sentiment': true,
    // try more options, sentiment analysis, intent, topics
  });

  DeepgramSttResult res = await deepgram.transcribeFromFile(file);

  var data = jsonDecode(res.json);
  if (data['results'] == null || data['results']['channels'] == null) {
    return [];
  }
  var result = data['results']['channels'][0]['alternatives'][0];
  List<TranscriptSegment> segments = [];
  for (var word in result['words']) {
    if (segments.isEmpty) {
      segments.add(TranscriptSegment(
          speaker: 'SPEAKER_${word['speaker']}',
          start: word['start'],
          end: word['end'],
          text: word['word'],
          isUser: false));
    } else {
      var lastSegment = segments.last;
      if (lastSegment.speakerId == word['speaker']) {
        lastSegment.text += ' ${word['word']}';
        lastSegment.end = word['end'];
      } else {
        segments.add(TranscriptSegment(
            speaker: 'SPEAKER_${word['speaker']}',
            start: word['start'],
            end: word['end'],
            text: word['word'],
            isUser: false));
      }
    }
  }
  return segments;
}

Future<String> webhookOnMemoryCreatedCall(Memory? memory,
    {bool returnRawBody = false}) async {
  if (memory == null) return '';
  return '';
}

Future<String> zapWebhookOnMemoryCreatedCall(Memory? memory,
    {bool returnRawBody = false}) async {
  if (memory == null) return '';

  // Retrieve preferences
  final isZapierEnabled = SharedPreferencesUtil().zapierEnabled;
  final webhookUrl = SharedPreferencesUtil().zapierWebhookUrl;

  // Check if Zapier integration is enabled and the webhook URL is valid
  if (!isZapierEnabled || webhookUrl.isEmpty) {
    return '';
  }

  // Prepare data payload for the webhook
  final data = {
    'title': memory.transcript, // Replace with your actual memory structure
    'description':
        memory.transcriptSegments, // Replace with your actual memory structure
    'timestamp': DateTime.now().toIso8601String(),
  };

  return triggerMemoryRequestAtEndpoint(
    webhookUrl, // Use the webhook URL from SharedPreferences
    data as Memory,
    returnRawBody: returnRawBody,
  );
}

Future<String> webhookOnTranscriptReceivedCall(
    List<TranscriptSegment> segments, String sessionId) async {
  return triggerTranscriptSegmentsRequest(
      SharedPreferencesUtil().webhookOnTranscriptReceived, sessionId, segments);
}

Future<String> getPluginMarkdown(String pluginMarkdownPath) async {
  // https://raw.githubusercontent.com/BasedHardware/Friend/main/assets/external_plugins_instructions/notion-conversations-crm.md
  var response = await makeApiCall(
    url:
        'https://raw.githubusercontent.com/BasedHardware/Friend/main$pluginMarkdownPath',
    method: 'GET',
    headers: {},
    body: '',
  );
  return response?.body ?? '';
}

Future<bool> isPluginSetupCompleted(String? url) async {
  if (url == null || url.isEmpty) return true;
  var response = await makeApiCall(
    url: '$url?uid=${SharedPreferencesUtil().uid}',
    method: 'GET',
    headers: {},
    body: '',
  );
  var data = jsonDecode(response?.body ?? '{}');
  return data['is_setup_completed'] ?? false;
}

Future<String> triggerMemoryRequestAtEndpoint(String url, Memory memory,
    {bool returnRawBody = false}) async {
  if (url.isEmpty) return '';
  if (url.contains('?')) {
    url += '&uid=${SharedPreferencesUtil().uid}';
  } else {
    url += '?uid=${SharedPreferencesUtil().uid}';
  }
  var data = memory.toJson();
  data['recordingFileBase64'] =
      await wavToBase64(memory.recordingFilePath ?? '');
  try {
    var response = await makeApiCall(
      url: url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
      method: 'POST',
    );
    if (returnRawBody) {
      return jsonEncode(
          {'statusCode': response?.statusCode, 'body': response?.body});
    }

    var body = jsonDecode(response?.body ?? '{}');
    return body['message'] ?? '';
  } catch (e) {
    // CrashReporting.reportHandledCrash(e, StackTrace.current, level: NonFatalExceptionLevel.warning, userAttributes: {
    //   'url': url,
    // });
    return '';
  }
}

Future<void> sendTaskToZapier(
    String title, String description, String time) async {
  final isZapierEnabled = SharedPreferencesUtil().zapierEnabled;
  final webhookUrl = SharedPreferencesUtil().zapierWebhookUrl;

  if (!isZapierEnabled || webhookUrl.isEmpty) {
    return;
  }

  final startTime = DateTime.parse(time);
  final endTime = startTime.add(Duration(minutes: 30));

  final data = {
    'title': title,
    'description': description,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
  };

  try {
    final response = await http.post(
      Uri.parse(webhookUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
    } else {}
  } catch (e) {
    log(e.toString());
  }
}

Future<String> triggerTranscriptSegmentsRequest(
    String url, String sessionId, List<TranscriptSegment> segments) async {
  if (url.isEmpty) return '';
  if (url.contains('?')) {
    url += '&uid=${SharedPreferencesUtil().uid}';
  } else {
    url += '?uid=${SharedPreferencesUtil().uid}';
  }
  try {
    var response = await makeApiCall(
      url: url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'session_id': sessionId,
        'segments': segments.map((e) => e.toJson()).toList(),
      }),
      method: 'POST',
    );
    var body = jsonDecode(response?.body ?? '{}');
    return body['message'] ?? '';
  } catch (e) {
    return '';
  }
}

Future<String?> wavToBase64(String filePath) async {
  if (filePath.isEmpty) return null;
  try {
    // Read file as bytes
    File file = File(filePath);
    if (!file.existsSync()) {
      return null;
    }
    List<int> fileBytes = await file.readAsBytes();

    // Encode bytes to base64
    String base64Encoded = base64Encode(fileBytes);

    return base64Encoded;
  } catch (e) {
    return null; // Handle error gracefully in your application
  }
}
