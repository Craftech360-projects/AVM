import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleDriveService {
  static const _scope = 'https://www.googleapis.com/auth/drive.file';
  static const _backupFileName = 'memories_backup.json';
  static const _folderName = 'altio_backup';
  static const _folderMimeType = 'application/vnd.google-apps.folder';

  final _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [_scope]);
  Future<String?> _getOrCreateFolder(drive.DriveApi driveApi) async {
    try {
      // Check if folder exists
      final folderList = await driveApi.files.list(
        q: "name='$_folderName' and mimeType='$_folderMimeType'",
        spaces: 'drive',
      );

      if (folderList.files?.isNotEmpty == true) {
        return folderList.files!.first.id;
      }

      // Create new folder
      final folder = drive.File()
        ..name = _folderName
        ..mimeType = _folderMimeType;

      final result = await driveApi.files.create(folder);
      return result.id;
    } on Exception catch (e) {
    log(e.toString());
      return null;
    }
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();

      if (account == null) {
        final GoogleSignInAccount? newAccount = await _googleSignIn.signIn();
        if (newAccount == null) {
          return null;
        }

        final GoogleSignInAuthentication auth = await newAccount.authentication;
        if (auth.accessToken == null) {
          return null;
        }

        await _storage.write(
            key: 'google_access_token', value: auth.accessToken);

        final authenticatedClient = AuthClient(auth.accessToken!);
        return drive.DriveApi(authenticatedClient);
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final authenticatedClient = AuthClient(auth.accessToken!);
      return drive.DriveApi(authenticatedClient);
    } on Exception catch (e) {
    log(e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>> uploadBackupToGoogleDrive(
      List<Map<String, dynamic>> data) async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        return {'success': false, 'url': null};
      }

      // Get or create folder
      final folderId = await _getOrCreateFolder(driveApi);
      if (folderId == null) return {'success': false, 'url': null};

      // Check for existing backup in folder
      final existingFile = await driveApi.files.list(
        q: "name='$_backupFileName' and '$folderId' in parents",
        spaces: 'drive',
      );

      final jsonString = json.encode(data);
      final dataBytes = utf8.encode(jsonString);

      String fileId;
      bool isUpdate = false;

      if (existingFile.files?.isNotEmpty == true) {
        // Update existing file
        final driveFile = drive.File()
          ..name = _backupFileName
          ..mimeType = 'application/json';

        final updated = await driveApi.files.update(
          driveFile,
          existingFile.files!.first.id!,
          uploadMedia:
              drive.Media(Stream.fromIterable([dataBytes]), dataBytes.length),
          addParents: folderId,
        );
        fileId = updated.id!;
        isUpdate = true;
      } else {
        // Create new file
        final driveFile = drive.File()
          ..name = _backupFileName
          ..parents = [folderId]
          ..mimeType = 'application/json';

        final created = await driveApi.files.create(
          driveFile,
          uploadMedia:
              drive.Media(Stream.fromIterable([dataBytes]), dataBytes.length),
        );
        fileId = created.id!;
      }

      // Set file permissions
      await driveApi.permissions.create(
        drive.Permission()
          ..type = 'anyone'
          ..role = 'reader',
        fileId,
      );

      // Get file metadata with links
      final fileMetadata = await driveApi.files.get(
        fileId,
        $fields: 'id,name,webViewLink,webContentLink',
      ) as drive.File;

      final fileUrl = fileMetadata.webViewLink;
      final downloadUrl = fileMetadata.webContentLink;

      return {
        'success': true,
        'fileId': fileId,
        'folderId': folderId,
        'isUpdate': isUpdate,
        'fileUrl': fileUrl,
        'downloadUrl': downloadUrl,
      };
    } on Exception catch (e) {
    log(e.toString());
      return {'success': false, 'url': null};
    }
  }

  Future<List<Map<String, dynamic>>?> restoreFromGoogleDrive() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        return null;
      }

      // Find the backup folder
      final folderId = await _getOrCreateFolder(driveApi);
      if (folderId == null) {
        return null;
      }

      // Search for backup file in the folder
      final fileList = await driveApi.files.list(
        q: "name='$_backupFileName' and '$folderId' in parents",
        spaces: 'drive',
      );

      if (fileList.files?.isEmpty ?? true) {
        return null;
      }

      final fileId = fileList.files!.first.id;
      if (fileId == null) {
        return null;
      }

      // Download file content
      final drive.Media file = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> dataBytes = await collectBytes(file.stream);
      final jsonString = utf8.decode(dataBytes);
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.cast<Map<String, dynamic>>();
    } on Exception catch (e) {
    log(e.toString());
      return null;
    }
  }

  Future<List<int>> collectBytes(Stream<List<int>> stream) async {
    final List<int> bytes = [];
    await for (final List<int> chunk in stream) {
      bytes.addAll(chunk);
    }
    return bytes;
  }

  // ignore: unused_element
  Future<String?> _findExistingBackup(drive.DriveApi driveApi) async {
    try {
      final fileList = await driveApi.files.list(
        q: "name = '$_backupFileName'",
        spaces: 'drive',
      );

      if (fileList.files?.isNotEmpty == true) {
        return fileList.files!.first.id;
      }
      return null;
    } on Exception catch (e) {
    log(e.toString());
      return null;
    }
  }
}

class AuthClient extends http.BaseClient {
  final String accessToken;
  final http.Client _client = http.Client();

  AuthClient(this.accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $accessToken';
    return _client.send(request);
  }
}
