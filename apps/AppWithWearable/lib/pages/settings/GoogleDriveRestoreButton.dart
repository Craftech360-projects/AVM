import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:friend_private/backend/api_requests/api/server.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/utils/features/googledrive.dart';

class BackupService {
  final GoogleDriveService _driveService = GoogleDriveService();

  // Encryption helpers
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

  // Regular backup to server
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

  // Manual backup to Google Drive (encrypted)
  Future<bool> executeManualBackupWithUid({String? uid}) async {
    if (!SharedPreferencesUtil().backupsEnabled) return false;

    print('executeManualBackupWithUid: $uid');
    final currentUid = uid ?? SharedPreferencesUtil().uid;

    try {
      var memories = MemoryProvider().getMemories();
      if (memories.isEmpty) return true;

      // Encrypt the data before uploading to Google Drive
      var rawData = memories.map((e) => e.toJson()).toList();
      var encodedData = encodeJson(rawData, currentUid);

      // Create a map with encrypted data and metadata
      final backupData = {
        'encrypted_data': encodedData,
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
      };

      print("Starting Google Drive backup");
      return await _driveService.uploadBackupToGoogleDrive([backupData]);
    } catch (e) {
      print('Error saving backup to Google Drive: $e');
      return false;
    }
  }

  // Restore from server
  Future<List<Memory>> retrieveBackupFromServer(String uid) async {
    print('retrieveBackupFromServer: $uid');

    var retrieved = await downloadBackupApi(uid);
    if (retrieved == '') return [];
    var memories = await getDecodedMemories(retrieved, uid);
    await MemoryProvider().storeMemories(memories);
    return memories;
  }

  // Restore from Google Drive
  Future<List<Memory>> retrieveBackupFromDrive(String uid) async {
    print('retrieveBackupFromDrive: $uid');
    try {
      final backupData = await _driveService.restoreFromGoogleDrive();
      if (backupData == null || backupData.isEmpty) {
        print('No backup found on Google Drive');
        return [];
      }

      // Get the encrypted data from the backup
      final encryptedData = backupData.first['encrypted_data'] as String;

      // Decrypt and convert to memories
      var memories = await getDecodedMemories(encryptedData, uid);
      await MemoryProvider().storeMemories(memories);

      print(
          'Successfully restored ${memories.length} memories from Google Drive');
      return memories;
    } catch (e) {
      print('Error retrieving backup from Google Drive: $e');
      return [];
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
}
