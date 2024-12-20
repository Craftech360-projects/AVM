import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:avm/backend/api_requests/api/shared.dart';
import 'package:avm/backend/preferences.dart';
import 'package:http/http.dart' as http;

const apiKey = "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";
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
  debugPrint("getOpenAIApiKeyForUsage");
  final apikey = getOpenAIApiKeyForUsage();
  debugPrint("$getOpenAIApiKeyForUsage(),$apikey");
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

// Future<dynamic> llamaApiCall({
//   required String message,
//   double temperature = 0.7,
//   int maxTokens = -1,
// }) async {
//   debugPrint("Inside LLaMA API call");

//   // Define the URL for the LLaMA API
//   const url = 'https://db1f-124-40-247-18.ngrok-free.app/v1/chat/completions';

//   // Define the headers for the request
//   final headers = {
//     'Content-Type': 'application/json',
//   };

//   // Construct the body of the request
//   final body = jsonEncode({
//     // Replace with specific model identifier if needed
//     'messages': [
//       {'role': 'system', 'content': ''' '''},
//       {
//         'role': 'user',
//         'content': " {$message}",
//       },
//     ],
//     'temperature': temperature,
//     'max_tokens': maxTokens,
//     'stream': false,
//   });

//   // Make the API call
//   try {
//     var response =
//         await http.post(Uri.parse(url), headers: headers, body: body);
//     if (response.statusCode == 200) {
//       debugPrint("Success: ${response.statusCode}, ${response.body}");
//       // print(">>>> $jsonDecode(response.body)");
//       // return jsonDecode(response.body);
//       var decodedResponse = jsonDecode(response.body);
//       // Extract and return only the content
//       debugPrint(decodedResponse['choices'][0]['message']['content']);
//       return decodedResponse['choices'][0]['message']['content'];
//     } else {
//       debugPrint("Error>>>>>: ${response.statusCode} ${response.reasonPhrase}");
//       return null;
//     }
//   } catch (e) {
//     debugPrint("Error making LLaMA API call: $e");
//     return null;
//   }
// }

Future<dynamic> llamaApiCall({
  required String message,
  double temperature = 0.7,
  int maxTokens = -1,
}) async {
  debugPrint("Inside LLaMA API call");

  // Define the URL for the LLaMA API
  const url = 'https://api.groq.com/openai/v1/chat/completions';

  // Define the headers for the request
  final headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer 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',
  };

  // Construct the body of the request
  final body = jsonEncode({
    // Replace with specific model identifier if needed
    "model": "llama3-8b-8192",
    'messages': [
      {'role': 'system', 'content': ''' '''},
      {
        'role': 'user',
        'content': " {$message}",
      },
    ],
    'temperature': temperature,
    'max_tokens': maxTokens,
    'stream': false,
    'response_format': {"type": "json_object"},
  });

  // Make the API call
  try {
    var response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      debugPrint("Success: ${response.statusCode}, ${response.body}");
      // print(">>>> $jsonDecode(response.body)");
      // return jsonDecode(response.body);
      var decodedResponse = jsonDecode(response.body);
      // Extract and return only the content
      debugPrint(decodedResponse['choices'][0]['message']['content']);
      return decodedResponse['choices'][0]['message']['content'];
    } else {
      debugPrint("Error>>>>>: ${response.statusCode} ${response.reasonPhrase}");
      return null;
    }
  } catch (e) {
    debugPrint("Error making LLaMA API call: $e");
    return null;
  }
}

Future<dynamic> llamaPluginApiCall({
  required String message,
  double temperature = 0.7,
  int maxTokens = -1,
}) async {
  debugPrint("Inside LLaMA API call");

  // Define the URL for the LLaMA API
  const url = 'https://api.groq.com/openai/v1/chat/completions';

  // Define the headers for the request
  final headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer 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',
  };

  // Construct the body of the request
  final body = jsonEncode({
    // Replace with specific model identifier if needed
    "model": "llama3-8b-8192",
    'messages': [
      {'role': 'system', 'content': ''' '''},
      {
        'role': 'user',
        'content': " {$message}",
      },
    ],
    'temperature': temperature,
    'max_tokens': maxTokens,
    'stream': false,
    'response_format': {"type": "text"},
  });

  // Make the API call
  try {
    var response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      debugPrint("Success: ${response.statusCode}, ${response.body}");
      // return jsonDecode(response.body);
      var decodedResponse = jsonDecode(response.body);
      // Extract and return only the content
      debugPrint(decodedResponse['choices'][0]['message']['content']);
      return decodedResponse['choices'][0]['message']['content'];
    } else {
      debugPrint("Error>>>>>: ${response.statusCode} ${response.reasonPhrase}");
      return null;
    }
  } catch (e) {
    debugPrint("Error making LLaMA API call: $e");
    return null;
  }
}

Future<String> executeGptPrompt(String? prompt,
    {bool ignoreCache = false}) async {
  if (prompt == null) return '';
  var prefs = SharedPreferencesUtil();
  var promptBase64 = base64Encode(utf8.encode(prompt));
  var cachedResponse = prefs.gptCompletionCache(promptBase64);
  if (!ignoreCache && prefs.gptCompletionCache(promptBase64).isNotEmpty) {
    return cachedResponse;
  }
  // print(">>>>>>>>>>>>>>>start");
  // api call using openai
  // String response = await gptApiCall(model: 'gpt-4o', messages: [
  //   {'role': 'system', 'content': prompt}
  // ]);

  //api call using llama

  String response = await llamaApiCall(
      message: prompt,
      temperature: 0.9, // Adjust temperature as needed
      maxTokens: 3000 // Adjust maxTokens as needed or set to -1 for default
      );
  debugPrint(">>>>>>>>>>>>>>>>??? $response");
  // debugPrint('executeGptPrompt response: $response');
  prefs.setGptCompletionCache(promptBase64, response);
  //debugPrint('executeGptPrompt response: $response');
  return response;
}

Future<String> executeGptPluginPrompt(String? prompt,
    {bool ignoreCache = false}) async {
  if (prompt == null) return '';
  var prefs = SharedPreferencesUtil();
  var promptBase64 = base64Encode(utf8.encode(prompt));
  var cachedResponse = prefs.gptCompletionCache(promptBase64);
  if (!ignoreCache && prefs.gptCompletionCache(promptBase64).isNotEmpty) {
    return cachedResponse;
  }
  // print(">>>>>>>>>>>>>>>start");
  // api call using openai
  // String response = await gptApiCall(model: 'gpt-4o', messages: [
  //   {'role': 'system', 'content': prompt}
  // ]);

  //api call using llama

  String response = await llamaPluginApiCall(
      message: prompt,
      temperature: 0.9, // Adjust temperature as needed
      maxTokens: 3000 // Adjust maxTokens as needed or set to -1 for default
      );
  debugPrint(">>>>>>>>>>>>>>>>??? $response");
  // debugPrint('executeGptPrompt response: $response');
  prefs.setGptCompletionCache(promptBase64, response);
  //debugPrint('executeGptPrompt response: $response');
  return response;
}
