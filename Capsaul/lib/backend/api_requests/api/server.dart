import 'dart:convert';
import 'dart:io';

import 'package:capsaul/backend/api_requests/api/shared.dart';
import 'package:capsaul/backend/database/transcript_segment.dart';
import 'package:capsaul/backend/preferences.dart';
import 'package:capsaul/backend/schema/plugin.dart';
import 'package:capsaul/backend/schema/sample.dart';
import 'package:capsaul/env/env.dart';
import 'package:http/http.dart' as http;
import 'package:instabug_flutter/instabug_flutter.dart';
import 'package:instabug_http_client/instabug_http_client.dart';
import 'package:path/path.dart';

Future<List<TranscriptSegment>> transcribe(File file) async {
  final client = InstabugHttpClient();
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(
        '${Env.apiBaseUrl}v1/transcribe?language=${SharedPreferencesUtil().recordingsLanguage}&uid=${SharedPreferencesUtil().uid}'),
  );
  request.files.add(await http.MultipartFile.fromPath('file', file.path,
      filename: basename(file.path)));
  request.headers.addAll({
    'Authorization': await getAuthHeader(),
  });

  try {
    var streamedResponse = await client.send(request);
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      return TranscriptSegment.fromJsonList(data);
    } else {
      throw Exception(
          'Failed to upload file. Status code: ${response.statusCode} Body: ${response.body}');
    }
  } catch (e) {
    rethrow;
  }
}

Future<bool> userHasSpeakerProfile(String uid) async {
  var response = await makeApiCall(
    url: '${Env.apiBaseUrl}v1/speech-profile?uid=$uid',
    // url: 'https://5818-107-3-134-29.ngrok-free.app/v1/speech-profile',
    headers: {},
    method: 'GET',
    body: '',
  );
  if (response == null) return false;

  return jsonDecode(response.body)['has_profile'] ?? false;
}

Future<List<SpeakerIdSample>> getUserSamplesState(String uid) async {
  var response = await makeApiCall(
    url: '${Env.apiBaseUrl}samples?uid=$uid',
    headers: {},
    method: 'GET',
    body: '',
  );
  if (response == null) return [];

  return SpeakerIdSample.fromJsonList(jsonDecode(response.body));
}

Future<bool> uploadSample(File file, String uid) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('${Env.apiBaseUrl}samples/upload?uid=$uid'),
  );
  request.files.add(await http.MultipartFile.fromPath('file', file.path,
      filename: basename(file.path)));

  try {
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
          'Failed to upload sample. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('An error occurred uploadSample: $e');
  }
}

Future<void> uploadBackupApi(String backup) async {
  // ignore: unused_local_variable
  var response = await makeApiCall(
    url: '${Env.apiBaseUrl}v1/backups?uid=${SharedPreferencesUtil().uid}',
    headers: {'Content-Type': 'application/json'},
    method: 'POST',
    body: jsonEncode({'data': backup}),
  );
}

Future<String> downloadBackupApi(String uid) async {
  var response = await makeApiCall(
    url: '${Env.apiBaseUrl}v1/backups?uid=$uid',
    headers: {},
    method: 'GET',
    body: '',
  );
  if (response == null) return '';

  return jsonDecode(response.body)['data'] ?? '';
}

Future<bool> deleteBackupApi() async {
  var response = await makeApiCall(
    url: '${Env.apiBaseUrl}v1/backups?uid=${SharedPreferencesUtil().uid}',
    headers: {},
    method: 'DELETE',
    body: '',
  );
  if (response == null) return false;

  return response.statusCode == 200;
}

Future<List<Plugin>> retrievePlugins() async {
  var response = await makeApiCall(
    url:
        'https://raw.githubusercontent.com/Craftech360-projects/AVM/main/community-plugins.json',
    headers: {},
    body: '',
    method: 'GET',
  );

  if (response == null) {
    return SharedPreferencesUtil().pluginsList;
  }

  if (response.statusCode == 200) {
    try {
      var plugins = Plugin.fromJsonList(jsonDecode(response.body));
      SharedPreferencesUtil().pluginsList = plugins;
      return plugins;
    } catch (e, stackTrace) {
      CrashReporting.reportHandledCrash(e, stackTrace);
      return SharedPreferencesUtil().pluginsList;
    }
  }

  return SharedPreferencesUtil().pluginsList;
}

Future<void> reviewPlugin(String pluginId, double score,
    {String review = ''}) async {
  await makeApiCall(
    url:
        '${Env.apiBaseUrl}v1/plugins/review?plugin_id=$pluginId&uid=${SharedPreferencesUtil().uid}',
    headers: {'Content-Type': 'application/json'},
    method: 'POST',
    body: jsonEncode({'score': score, review: review}),
  );
}

Future<void> migrateUserServer(String prevUid, String newUid) async {
  await makeApiCall(
    url: '${Env.apiBaseUrl}migrate-user?prev_uid=$prevUid&new_uid=$newUid',
    headers: {},
    method: 'POST',
    body: '',
  );
}
