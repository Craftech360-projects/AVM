import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter/material.dart';
import 'package:friend_private/backend/api_requests/api/shared.dart';
import 'package:friend_private/backend/preferences.dart';

Future<dynamic> gptApiCall({
  required String model,
  String urlSuffix = 'chat/completions',
  List<Map<String, dynamic>> messages = const [],
  String contentToEmbed = '',
  bool jsonResponseFormat = false,
  List tools = const [],
  File? audioFile,
  double temperature = 0.3,
  int? maxTokens,
}) async {
  print("getOpenAIApiKeyForUsage");
  final apikey = await getOpenAIApiKeyForUsage();
  print("$getOpenAIApiKeyForUsage(),$apikey");
  final url = 'https://api.openai.com/v1/$urlSuffix';
  final headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Authorization': 'Bearer $apikey',
  };
  final String body;
  if (urlSuffix == 'embeddings') {
    body = jsonEncode({'model': model, 'input': contentToEmbed});
  } else {
    var bodyData = {
      'model': model,
      'messages': messages,
      'temperature': temperature
    };
    if (jsonResponseFormat) {
      bodyData['response_format'] = {'type': 'json_object'};
    } else if (tools.isNotEmpty) {
      bodyData['tools'] = tools;
      bodyData['tool_choice'] = 'auto';
    }
    if (maxTokens != null) {
      bodyData['max_tokens'] = maxTokens;
    }
    body = jsonEncode(bodyData);
  }

  var response =
      await makeApiCall(url: url, headers: headers, body: body, method: 'POST');
  return extractContentFromResponse(
    response,
    isEmbedding: urlSuffix == 'embeddings',
    isFunctionCalling: tools.isNotEmpty,
  );
}

//api call using  the Llama 3.1

// Assuming `getOpenAIApiKeyForUsage` and `makeApiCall` are defined elsewhere.

// API call using the LLaMA model

Future<dynamic> llamaApiCall({
  required String message,
  double temperature = 0.7,
  int maxTokens = -1,
}) async {
  print("Inside LLaMA API call");

  // Define the URL for the LLaMA API
  const url = 'https://9cd8-124-40-247-18.ngrok-free.app/v1/chat/completions';

  // Define the headers for the request
  final headers = {
    'Content-Type': 'application/json',
  };

  // Construct the body of the request
  final body = jsonEncode({
    // Replace with specific model identifier if needed
    'messages': [
      {
        'role': 'system',
        'content':
            '''Your task is to provide structure and clarity to the recording transcription of a conversation. Use English for your response. Format your response as a JSON object with the following structure:
        {
          "title": "Main topic of the conversation",
          "overview": "Condensed summary with main topics discussed",
          "action_items": ["List of commitments or tasks"],
          "category": "Classification of the conversation",
          "events": [
            {
              "title": "Event title",
              "description": "Brief description",
              "startsAt": "Start date and time in ISO format",
              "duration": "Duration in minutes (integer)"
            }
          ]
        }
        The date context for this conversation is ${DateTime.now().toIso8601String()}.'''
      },
      {
        'role': 'user',
        'content': " {$message}",
      },
    ],
    'temperature': temperature,
    'max_tokens': maxTokens,
    'stream': false,
  });

  // Make the API call
  try {
    var response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      print("Success: ${response.statusCode}, ${response.body}");
      // print(">>>> $jsonDecode(response.body)");
      // return jsonDecode(response.body);
      var decodedResponse = jsonDecode(response.body);
      // Extract and return only the content
      print(decodedResponse['choices'][0]['message']['content']);
      return decodedResponse['choices'][0]['message']['content'];
    } else {
      print("Error>>>>>: ${response.statusCode} ${response.reasonPhrase}");
      return null;
    }
  } catch (e) {
    print("Error making LLaMA API call: $e");
    return null;
  }
}

Future<String> executeGptPrompt(String? prompt,
    {bool ignoreCache = false}) async {
  if (prompt == null) return '';
  print("executing prompt here>>>>>>>>>>>>>>>");
  var prefs = SharedPreferencesUtil();
  var promptBase64 = base64Encode(utf8.encode(prompt));
  var cachedResponse = prefs.gptCompletionCache(promptBase64);
  if (!ignoreCache && prefs.gptCompletionCache(promptBase64).isNotEmpty)
    return cachedResponse;
  print(">>>>>>>>>>>>>>>start");
  //api call using openai
  // String response = await gptApiCall(model: 'gpt-4o', messages: [
  //   {'role': 'system', 'content': prompt}
  // ]);

  //api call using llama

  String response = await llamaApiCall(
      message: prompt,
      temperature: 0.7, // Adjust temperature as needed
      maxTokens: 1000 // Adjust maxTokens as needed or set to -1 for default
      );
  print(">>>>>>>>>>>>>>>>??? $response");
  debugPrint('executeGptPrompt response: $response');
  prefs.setGptCompletionCache(promptBase64, response);
  //debugPrint('executeGptPrompt response: $response');
  return response;
}
