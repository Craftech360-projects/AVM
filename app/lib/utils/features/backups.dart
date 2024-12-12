import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:friend_private/backend/api_requests/api/server.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/utils/features/googledrive.dart';

String encodeJson(List<dynamic> jsonObj, String password) {
  String jsonString = json.encode(jsonObj);
  final key = encrypt.Key.fromUtf8(
      sha256.convert(utf8.encode(password)).toString().substring(0, 32));
  final iv = encrypt.IV.fromSecureRandom(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final encrypted = encrypter.encrypt(jsonString, iv: iv);
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

Future<bool> executeBackupWithUid({String? uid}) async {
  if (!SharedPreferencesUtil().backupsEnabled) return false;
  print('executeBackupWithUid: $uid');

  var memories = MemoryProvider().getMemories();
  if (memories.isEmpty) return true;
  var encoded = encodeJson(memories.map((e) => e.toJson()).toList(),
      uid ?? SharedPreferencesUtil().uid);

  await uploadBackupApi(encoded);
  return true;
}

Future<bool> executeManualBackupWithUid(uid) async {
  if (!SharedPreferencesUtil().backupsEnabled) return false;

  print('executeBackupWithUid: $uid');

  var memories = MemoryProvider().getMemories();

  if (memories.isEmpty) return true;

  var rawData =
      memories.map((e) => e.toJson() as Map<String, dynamic>).toList();

  try {
    print("start backup");
    //uploadBackupToGoogleDrive(rawData);
    final googleDriveService = GoogleDriveService();
    print(googleDriveService);
    return await googleDriveService.uploadBackupToGoogleDrive(rawData);
  } catch (e) {
    print('Error saving backup: $e');
    return false;
  }
}

Future<List<Memory>> restoreFromBackup(
    {String? uid, dynamic backupData}) async {
  if (backupData == null) return [];
  print('Retrieving backup for uid: $uid');

  try {
    List<Map<String, dynamic>> decodedData;

    // Check if the backup is encrypted (string) or raw (List<Map>)
    if (backupData is String) {
      // Handle encrypted backup
      try {
        final currentUid = uid ?? SharedPreferencesUtil().uid;
        decodedData =
            List<Map<String, dynamic>>.from(decodeJson(backupData, currentUid));
      } catch (e) {
        print('Error decoding backup: $e');
        return [];
      }
    } else if (backupData is List) {
      // Handle raw backup data
      decodedData = List<Map<String, dynamic>>.from(backupData);
    } else {
      print('Invalid backup data format');
      return [];
    }

    // Convert JSON to Memory objects
    // List<Memory> memoriesToRestore = decodedData.map((json) {
    //   try {
    //     // Check and convert memoryImg if it's a List<dynamic>
    //     if (json['memoryImg'] is List<dynamic>) {
    //       json['memoryImg'] =
    //           Uint8List.fromList(List<int>.from(json['memoryImg']));
    //     }
    //     return Memory.fromJson(json);
    //   } catch (e) {
    //     print('Error converting json to memory: $e');
    //     rethrow;
    //   }
    // }).toList();
    List<Memory> memoriesToRestore = decodedData.map((json) {
      try {
        if (json['memoryImg'] is List<dynamic>) {
          // If memoryImg is a list, convert it to Uint8List
          json['memoryImg'] =
              Uint8List.fromList(List<int>.from(json['memoryImg']));
        } else if (json['memoryImg'] is String) {
          // If memoryImg is a String, assume it's Base64-encoded and decode it
          json['memoryImg'] = base64Decode(json['memoryImg']);
        } else if (json['memoryImg'] == null) {
          // Handle null if memoryImg is optional
          json['memoryImg'] = null;
        } else {
          throw Exception(
              "Unsupported type for memoryImg: ${json['memoryImg'].runtimeType}");
        }

        return Memory.fromJson(json);
      } catch (e) {
        print('Error converting json to memory: $e');
        rethrow;
      }
    }).toList();

    return memoriesToRestore;
  } catch (e) {
    print('Error in restore process: $e');
    return [];
  }
}

Future<bool> retrieveBackup(String? uid) async {
  print('retrieveBackup: $uid');

  try {
    final googleDriveService = GoogleDriveService();
    final backupData = await googleDriveService.restoreFromGoogleDrive();

    // Check for null or empty backup data
    if (backupData == null || backupData.isEmpty) {
      print('No backup found on Google Drive');
      return false;
    }

    debugPrint("backup>>>>>>>> ${backupData.toString()}");

    try {
      // Attempt to restore from backup
      var memories = await restoreFromBackup(uid: uid, backupData: backupData);
      if (memories.isNotEmpty) {
        print("here,sucesss");
        print(memories);
        // Store the memories only if we successfully restored them
        MemoryProvider().storeMemories(memories);
        print("Backup restored successfully");
      }
      return true;
    } catch (e) {
      print("Error restoring backup: ${e.toString()}");
      return false;
    }
  } catch (e) {
    print("Error in retrieving backup: ${e.toString()}");
    return false;
  }
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
