import 'dart:convert';
import 'dart:developer';

import 'package:altio/backend/preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './streaming_models.dart';

Future<String> generateRequestBody(String prompt) async {
  String selectedModel = SharedPreferencesUtil().selectedModel;

  return jsonEncode({
    "model": selectedModel,
    "messages": [
      {"role": "system", "content": ""},
      {"role": "user", "content": prompt}
    ],
    "temperature": 1,
    "max_tokens":
        selectedModel == "deepseek-r1-distill-llama-70b" ? 131072 : 32768,
    "stream": true,
  });
}

void switchModel(bool useDeepSeek) {
  SharedPreferencesUtil().selectedModel =
      useDeepSeek ? "deepseek-r1-distill-llama-70b" : "llama-3.3-70b-versatile";
}

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

  // ✅ Get the model dynamically from SharedPreferences
  String selectedModel = SharedPreferencesUtil().selectedModel;
  // ✅ Use the dynamic model in the request body
  var body = jsonEncode({
    "model": selectedModel,
    "messages": [
      {"role": "system", "content": ""},
      {"role": "user", "content": prompt}
    ],
    "temperature": 1,
    "max_tokens":
        selectedModel == "deepseek-r1-distill-llama-70b" ? 131072 : 32768,
    "stream": true,
  });

  var request = http.Request("POST", Uri.parse(url))
    ..headers.addAll(headers)
    ..body = body;

  try {
    final http.StreamedResponse response = await client.send(request);
    if (response.statusCode == 401) {
      await callback('Incorrect API Key provided.');
      return;
    } else if (response.statusCode == 429) {
      await callback('You have reached the API limit.');
      return;
    } else if (response.statusCode != 200) {
      await callback('Unknown Error with LLaMA API.');
      return;
    }

    await _processStream(response, callback, onDone);
  } on Exception catch (e) {
    log('Error sending request: $e');
  }
}

Future<void> _processStream(
  http.StreamedResponse response,
  Future<dynamic> Function(String) callback,
  VoidCallback onDone,
) async {
  // Create a StringBuffer to accumulate the content from the stream
  StringBuffer accumulatedContent = StringBuffer();

  await response.stream
      .transform(utf8.decoder) // Decode the stream as UTF-8 text
      .transform(const LineSplitter()) // Split the text into lines
      .listen(
        (String line) async {
          if (line.startsWith('data: ')) {
            String jsonData =
                line.substring(6).trim(); // Remove 'data: ' prefix

            if (jsonData == '[DONE]') {
              // Stream is done, trigger onDone callback
              onDone();
              // Print the final accumulated content
            } else {
              try {
                var data = jsonDecode(jsonData); // Decode the JSON data
                String content = data['choices'][0]['delta']['content'] ?? '';

                if (content.isNotEmpty) {
                  // Accumulate the content as it arrives
                  accumulatedContent.writeln(content);
                  // Call the callback with the content
                  await callback(content);
                }
              } on Exception catch (e) {
                log('Error processing chunk: $e');
              }
            }
          }
        },
        onDone: onDone, // This will be called when the stream is done
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
  } on Exception catch (e) {
    log(e.toString());
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
          jsonEncodeString(contentResponse.choices![0].delta!.content)!;
      callback(content);
    }
  }
}

Future<void> printFinalMessage(String content) async {}
