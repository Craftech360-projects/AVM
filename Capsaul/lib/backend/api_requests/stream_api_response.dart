import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './streaming_models.dart';

Future streamApiResponse(
  String prompt,
  Future<dynamic> Function(String) callback,
  VoidCallback onDone,
) async {
  var client = http.Client();
  const url = 'https://api.groq.com/openai/v1/chat/completions';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer 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',
  };

  var body = jsonEncode({
    "model": "llama-3.1-70b-versatile",
    "messages": [
      {"role": "system", "content": ""},
      {"role": "user", "content": prompt}
    ],
    "stream": true,
  });

  var request = http.Request("POST", Uri.parse(url))
    ..headers.addAll(headers)
    ..body = body;

  try {
    final http.StreamedResponse response = await client.send(request);
    if (response.statusCode == 401) {
      callback('Incorrect API Key provided.');
      return;
    } else if (response.statusCode == 429) {
      callback('You have reached the API limit.');
      return;
    } else if (response.statusCode != 200) {
      callback('Unknown Error with LLaMA API.');
      return;
    }

    log('Stream response: ${response.statusCode}');

    await _processStream(response, callback, onDone);
  } catch (e) {
    log('Error sending request: $e');
  }
}

Future<void> _processStream(
  http.StreamedResponse response,
  Future<dynamic> Function(String) callback,
  VoidCallback onDone,
) async {
  await response.stream
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen(
        (String line) async {
          if (line.startsWith('data: ')) {
            String jsonData = line.substring(6).trim();
            if (jsonData == '[DONE]') {
              onDone();
            } else {
              try {
                var data = jsonDecode(jsonData);
                String content = data['choices'][0]['delta']['content'] ?? '';
                if (content.isNotEmpty) {
                  await callback(content);
                }
              } catch (e) {
                log('Error processing chunk: $e');
              }
            }
          }
        },
        onDone: onDone,
        onError: (error) {
          log('Error in stream: $error');
        },
      )
      .asFuture();
}

bool isValidJson(String jsonString) {
  try {
    json.decode(jsonString);
    return true;
  } catch (e) {
    return false;
  }
}

String? jsonEncodeString(String? regularString) {
  if (regularString == null) return null;
  if (regularString.isEmpty | (regularString.length == 1)) return regularString;

  String encodedString = jsonEncode(regularString);
  return encodedString.substring(1, encodedString.length - 1);
}

void handlePartialResponseContent(
    String data, Future<dynamic> Function(String) callback) {
  if (data.contains("content")) {
    ContentResponse contentResponse =
        ContentResponse.fromJson(jsonDecode(data));
    if (contentResponse.choices != null &&
        contentResponse.choices![0].delta != null &&
        contentResponse.choices![0].delta!.content != null) {
      String content =
          jsonEncodeString(contentResponse.choices![0].delta!.content!)!;
      callback(content);
    }
  }
}
