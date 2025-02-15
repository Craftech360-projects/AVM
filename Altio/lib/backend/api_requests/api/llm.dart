import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:altio/backend/api_requests/api/shared.dart';
import 'package:altio/backend/preferences.dart';
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
  final apikey = getOpenAIApiKeyForUsage();
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

Future<dynamic> llamaApiCall({
  required String message,
  double temperature = 1,
}) async {
  const url = 'https://api.groq.com/openai/v1/chat/completions';

  // ✅ Fetch the selected model from SharedPreferences
  String model = SharedPreferencesUtil().selectedModel;

  // ✅ Dynamically set maxTokens based on model
  int maxTokens = (model == "deepseek-r1-distill-llama-70b") ? 131072 : 32768;

  final headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer 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',
  };

  // ✅ Only add `response_format` for models that support it
  Map<String, dynamic> bodyData = {
    "model": model,
    'messages': [
      {'role': 'system', 'content': ''},
      {'role': 'user', 'content': message},
    ],
    'temperature': temperature,
    'max_tokens': maxTokens,
    'stream': false,
  };

  if (model != "deepseek-r1-distill-llama-70b") {
    bodyData['response_format'] = {"type": "json_object"};
  }

  final body = jsonEncode(bodyData);

  try {
    var response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(response.body);
      return decodedResponse['choices'][0]['message']['content'];
    } else {
      log("Error ---->: ${response.statusCode} ${response.reasonPhrase}");
      return null;
    }
  } on Exception catch (e) {
    log("Error making LLaMA API call: $e");
    return null;
  }
}

Future<dynamic> llamaPluginApiCall({
  required String message,
  double temperature = 1,
  int maxTokens = 32500,
}) async {
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
    "model": "llama-3.3-70b-versatile",
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
      // return jsonDecode(response.body);
      var decodedResponse = jsonDecode(response.body);
      // Extract and return only the content
      return decodedResponse['choices'][0]['message']['content'];
    } else {
      log("Error ---->: ${response.statusCode} ${response.reasonPhrase}");
      return null;
    }
  } on Exception catch (e) {
    log("Error making LLaMA API call: $e");
    return null;
  }
}

Future<dynamic> llamaPluginApiCallPlainText({
  required String message,
  double temperature = 1,
}) async {
  // Define the URL for the LLaMA API
  const url = 'https://api.groq.com/openai/v1/chat/completions';

  // ✅ Fetch the selected model from SharedPreferences
  String model = SharedPreferencesUtil().selectedModel;

  // ✅ Set maxTokens dynamically based on model
  int maxTokens = (model == "deepseek-r1-distill-llama-70b") ? 131072 : 32768;

  // Define the headers for the request
  final headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer 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',
  };

  // ✅ Construct the request body
  Map<String, dynamic> bodyData = {
    "model": model,
    'messages': [
      {'role': 'system', 'content': ''},
      {'role': 'user', 'content': message},
    ],
    'temperature': temperature,
    'max_tokens': maxTokens,
    'stream': false,
  };

  // ✅ Only include `response_format` if the model supports it
  if (model != "deepseek-r1-distill-llama-70b") {
    bodyData['response_format'] = {"type": "text"};
  }

  final body = jsonEncode(bodyData);

  // Make the API call
  try {
    var response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      String responseBody = response.body;

      var decodedResponse = jsonDecode(responseBody);

      // Extract the AI message content and remove <think> tags
      String finalResponseBody =
          decodedResponse['choices'][0]['message']['content'] ?? "";
      finalResponseBody = finalResponseBody.replaceAll(
          RegExp(r'\<think\>.*?\<\/think\>\s*', dotAll: true), '');

      // ✅ Now parse the cleaned JSON response

      // ✅ Return the cleaned content
      return finalResponseBody;
    } else {
      log("Error ---->: ${response.statusCode} ${response.reasonPhrase}");
      return null;
    }
  } on Exception catch (e) {
    log("Error making LLaMA API call: $e");
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

  //api call using llama
  String response = await llamaApiCall(
    message: prompt,
    temperature: 1, // Adjust temperature as needed
    // Adjust maxTokens as needed or set to -1 for default
  );

  prefs.setGptCompletionCache(promptBase64, response);

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

  //api call using llama
  String response = await llamaPluginApiCall(
      message: prompt,
      temperature: 1, // Adjust temperature as needed
      maxTokens: 32500 // Adjust maxTokens as needed or set to -1 for default
      );

  prefs.setGptCompletionCache(promptBase64, response);

  return response;
}

Future<String> executeGptPromptPlainText(String? prompt,
    {bool ignoreCache = false}) async {
  if (prompt == null) return '';
  var prefs = SharedPreferencesUtil();
  var promptBase64 = base64Encode(utf8.encode(prompt));
  var cachedResponse = prefs.gptCompletionCache(promptBase64);
  if (!ignoreCache && prefs.gptCompletionCache(promptBase64).isNotEmpty) {
    return cachedResponse;
  }

  //api call using llama
  String response = await llamaPluginApiCallPlainText(
    message: prompt,
    temperature: 1, // Adjust temperature as needed
    // Adjust maxTokens as needed or set to -1 for default
  );

  prefs.setGptCompletionCache(promptBase64, response);
  return response;
}
