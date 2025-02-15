import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:altio/backend/preferences.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

AuthClient? authClient;

Future<void> authenticateGCP({String? base64}) async {
  var credentialsBase64 = base64 ?? SharedPreferencesUtil().gcpCredentials;
  if (credentialsBase64.isEmpty) {
    return;
  }
  final credentialsBytes = base64Decode(credentialsBase64);
  String decodedString = utf8.decode(credentialsBytes);
  final credentials =
      ServiceAccountCredentials.fromJson(jsonDecode(decodedString));
  var scopes = ['https://www.googleapis.com/auth/devstorage.full_control'];
  authClient = await clientViaServiceAccount(credentials, scopes);
}

Future<String?> uploadFile(File file, {bool prefixTimestamp = false}) async {
  String bucketName = SharedPreferencesUtil().gcpBucketName;
  if (bucketName.isEmpty) {
    return null;
  }
  String fileName = file.path.split('/')[file.path.split('/').length - 1];
  if (prefixTimestamp) {
    fileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
  }
  String url =
      'https://storage.googleapis.com/upload/storage/v1/b/$bucketName/o?uploadType=media&name=$fileName';

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${authClient?.credentials.accessToken.data}',
        'Content-Type': 'audio/wav',
      },
      body: file.readAsBytesSync(),
    );

    if (response.statusCode == 200) {
      jsonDecode(response.body);
      return fileName;
    } else {
      log('Failed to upload: ${response.body}');
    }
  } on Exception catch (e) {
    log('Error uploading file: $e');
  }
  return null;
}

// Download file method
Future<File?> downloadFile(String objectName, String saveFileName) async {
  final directory = await getApplicationDocumentsDirectory();
  String saveFilePath = '${directory.path}/$saveFileName';
  if (File(saveFilePath).existsSync()) {
    return File(saveFilePath);
  }

  String bucketName = SharedPreferencesUtil().gcpBucketName;
  if (bucketName.isEmpty) {
    return null;
  }

  try {
    var response = await http.get(
      Uri.parse(
          'https://storage.googleapis.com/storage/v1/b/$bucketName/o/$objectName?alt=media'),
      headers: {
        'Authorization': 'Bearer ${authClient?.credentials.accessToken.data}'
      },
    );

    if (response.statusCode == 200) {
      final file = File('${directory.path}/$saveFileName');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      log('Failed to download: ${response.body}');
    }
  } on Exception catch (e) {
    log('Error downloading file: $e');
  }
  return null;
}
