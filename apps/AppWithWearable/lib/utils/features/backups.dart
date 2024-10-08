import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:friend_private/backend/api_requests/api/server.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/preferences.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io'; // For file system
// For getting directories
import 'package:permission_handler/permission_handler.dart'; // For requesting permissions

String encodeJson(List<dynamic> jsonObj, String password) {
  String jsonString = json.encode(jsonObj);
  final key = encrypt.Key.fromUtf8(
      sha256.convert(utf8.encode(password)).toString().substring(0, 32));
  final iv = encrypt.IV.fromSecureRandom(16); // Generate a random IV
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final encrypted = encrypter.encrypt(jsonString, iv: iv);
  // Return the encrypted string with the IV prepended
  return '${iv.base64}:${encrypted.base64}';
}

List<dynamic> decodeJson(String encryptedJson, String password) {
  final parts = encryptedJson.split(':');
  if (parts.length != 2) {
    throw Exception('Invalid encrypted data format.');
  }
  final iv = encrypt.IV.fromBase64(parts[0]);
  final encryptedData = parts[1];

  final key = encrypt.Key.fromUtf8(
      sha256.convert(utf8.encode(password)).toString().substring(0, 32));
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final decrypted = encrypter.decrypt64(encryptedData, iv: iv);
  return json.decode(decrypted);
}

// Future<String> getEncodedMemories() async {
//   var password = SharedPreferencesUtil().backupPassword;
//   if (password.isEmpty) return '';
//   var memories = MemoryProvider().getMemories();
//   return encodeJson(memories.map((e) => e.toJson()).toList(), password);
// }

// Future<bool> executeBackup() async {
//   if (!SharedPreferencesUtil().backupsEnabled) return false;
//   var result = await getEncodedMemories();
//   if (result == '') return false;
//   await getDecodedMemories(result, SharedPreferencesUtil().backupPassword);
//   SharedPreferencesUtil().lastBackupDate = DateTime.now().toIso8601String();
//   await uploadBackupApi(result);
//   return true;
// }

Future<bool> executeBackupWithUid({String? uid}) async {
  if (!SharedPreferencesUtil().backupsEnabled) return false;
  print('executeBackupWithUid: $uid');

  var memories = MemoryProvider().getMemories();
  if (memories.isEmpty) return true;
  var encoded = encodeJson(memories.map((e) => e.toJson()).toList(),
      uid ?? SharedPreferencesUtil().uid);
  // SharedPreferencesUtil().lastBackupDate = DateTime.now().toIso8601String();
  await uploadBackupApi(encoded);
  return true;
}
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';

// Future<bool> executeManualBackupWithUid({String? uid}) async {
//   // Check if backups are enabled
//   if (!SharedPreferencesUtil().backupsEnabled) return false;

//   print('executeBackupWithUid: $uid');

//   // Get the memories (data) that needs to be backed up
//   var memories = MemoryProvider().getMemories();

//   // If there's no data to back up, return true (no need to proceed)
//   if (memories.isEmpty) return true;

//   // Encode the memories to JSON format and include the uid if provided or use the stored one
//   var encoded = encodeJson(
//     memories.map((e) => e.toJson()).toList(),
//     uid ?? SharedPreferencesUtil().uid,
//   );
//   try {
//     // Get the application documents directory
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File(
//         '${directory.path}/backup_${DateTime.now().millisecondsSinceEpoch}.json');

//     // Write the encoded data to the file
//     await file.writeAsString(encoded);

//     print('Backup saved to: ${file.path}');

//     // Update the last backup date
//     // SharedPreferencesUtil().lastBackupDate = DateTime.now().toIso8601String();

//     return true;
//   } catch (e) {
//     print('Error saving backup: $e');
//     return false;
//   }
//   // Uncomment the following line to upload the backup data via an API call
//   // await uploadBackupApi(encoded);

//   // Optionally, update the last backup date
//   // SharedPreferencesUtil().lastBackupDate = DateTime.now().toIso8601String();

//   return true;
// }

// For external storage

Future<bool> executeManualBackupWithUid({String? uid}) async {
  if (!SharedPreferencesUtil().backupsEnabled) return false;

  print('executeBackupWithUid: $uid');

  var memories = MemoryProvider().getMemories();

  if (memories.isEmpty) return true;

  // var encoded = encodeJson(
  //   memories.map((e) => e.toJson()).toList(),
  //   uid ?? SharedPreferencesUtil().uid,
  // );
  var rawData = memories.map((e) => e.toJson()).toList();

  try {
    // Save to external storage (accessible directory)
    final directory =
        await getExternalStorageDirectory(); // Modified to use external storage
    print(directory);
    final file = File(
        '${directory!.path}/backup_${DateTime.now().millisecondsSinceEpoch}.json');

    await file.writeAsString(jsonEncode(rawData));

    print('Backup saved to: ${file.path}');
    return true;
  } catch (e) {
    print('Error saving backup: $e');
    return false;
  }
}

Future<List<Memory>> retrieveBackup(String uid) async {
  print('retrieveBackup: $uid');
  var retrieved = await downloadBackupApi(uid);
  if (retrieved == '') return [];
  var memories = await getDecodedMemories(retrieved, uid);
  MemoryProvider().storeMemories(memories);
  return memories;
}

Future<List<Memory>> getDecodedMemories(
    String encodedMemories, String password) async {
  if (password.isEmpty) return [];
  try {
    var decoded = decodeJson(encodedMemories, password);
    return decoded.map((e) => Memory.fromJson(e)).toList();
  } catch (e) {
    throw Exception('The password is incorrect.');
  }
}
