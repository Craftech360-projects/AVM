import 'dart:convert';

import 'package:capsoul/backend/auth.dart';
import 'package:capsoul/backend/preferences.dart';
import 'package:http/http.dart' as http;
import 'package:instabug_http_client/instabug_http_client.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

Future<String> getAuthHeader() async {
  if (SharedPreferencesUtil().authToken == '') {
    SharedPreferencesUtil().authToken = await getIdToken() ?? '';
  }
  if (SharedPreferencesUtil().authToken == '') {
    throw Exception('No auth token found');
  }
  return 'Bearer ${SharedPreferencesUtil().authToken}';
}

Future<http.Response?> makeApiCall({
  required String url,
  required Map<String, String> headers,
  required String body,
  required String method,
}) async {
  try {
    bool result = await InternetConnection().hasInternetAccess; // 600 ms on avg
    if (!result) {
      return null;
    }

    final client = InstabugHttpClient();

    if (method == 'POST') {
      return await client.post(Uri.parse(url), headers: headers, body: body);
    } else if (method == 'GET') {
      return await client.get(Uri.parse(url), headers: headers);
    } else if (method == 'DELETE') {
      return await client.delete(Uri.parse(url), headers: headers);
    } else {
      throw Exception('Unsupported HTTP method: $method');
    }
  } catch (e) {
    return null;
  } finally {}
}

// Function to extract content from the API response.
dynamic extractContentFromResponse(
  http.Response? response, {
  bool isEmbedding = false,
  bool isFunctionCalling = false,
}) {
  if (response != null && response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (isEmbedding) {
      var embedding = data['data'][0]['embedding'];
      return embedding;
    }
    var message = data['choices'][0]['message'];
    if (isFunctionCalling && message['tool_calls'] != null) {
      return message['tool_calls'];
    }
    return data['choices'][0]['message']['content'];
  } else {
    return null;
  }
}
