import 'dart:convert';

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
        print('Found existing folder: ${folderList.files!.first.id}');
        return folderList.files!.first.id;
      }

      // Create new folder
      final folder = drive.File()
        ..name = _folderName
        ..mimeType = _folderMimeType;

      final result = await driveApi.files.create(folder);
      print('Created new folder: ${result.id}');
      return result.id;
    } catch (e) {
      print('Error creating/finding folder: $e');
      return null;
    }
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    try {
      print('Attempting silent sign in...');
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();

      if (account == null) {
        print('Silent sign in failed, attempting interactive sign in...');
        final GoogleSignInAccount? newAccount = await _googleSignIn.signIn();
        if (newAccount == null) {
          print('Interactive sign in failed - user canceled');
          return null;
        }

        print('Interactive sign in successful for: ${newAccount.email}');
        final GoogleSignInAuthentication auth = await newAccount.authentication;
        if (auth.accessToken == null) {
          print('Failed to get access token');
          return null;
        }

        print('Storing new access token...');
        await _storage.write(
            key: 'google_access_token', value: auth.accessToken);

        final authenticatedClient = AuthClient(auth.accessToken!);
        return drive.DriveApi(authenticatedClient);
      }

      print('Silent sign in successful for: ${account.email}');
      final GoogleSignInAuthentication auth = await account.authentication;
      final authenticatedClient = AuthClient(auth.accessToken!);
      return drive.DriveApi(authenticatedClient);
    } catch (e) {
      print('Error in _getDriveApi: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> uploadBackupToGoogleDrive(
      List<Map<String, dynamic>> data) async {
    try {
      print('Starting backup upload...');
      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        print('Failed to get Drive API client');
        return {'success': false, 'url': null};
      }

      // Get or create folder
      final folderId = await _getOrCreateFolder(driveApi);
      if (folderId == null) return {'success': false, 'url': null};

      // Check for existing backup in folder
      print('Checking for existing backup in folder: $folderId');
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
        print('Updating existing backup file: ${existingFile.files!.first.id}');
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
        print('Creating new backup file');
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
      print('Setting file permissions...');
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

      print('Backup file URL: $fileUrl');
      print('Backup file download URL: $downloadUrl');

      return {
        'success': true,
        'fileId': fileId,
        'folderId': folderId,
        'isUpdate': isUpdate,
        'fileUrl': fileUrl,
        'downloadUrl': downloadUrl,
      };
    } catch (e) {
      print('Upload error: $e');
      return {'success': false, 'url': null};
    }
  }

  Future<List<Map<String, dynamic>>?> restoreFromGoogleDrive() async {
    try {
      print('Starting backup restore...');
      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        print('Failed to get Drive API client');
        return null;
      }

      // Find the backup folder
      final folderId = await _getOrCreateFolder(driveApi);
      if (folderId == null) {
        print('Backup folder not found');
        return null;
      }

      // Search for backup file in the folder
      print('Looking for backup file in folder: $folderId');
      final fileList = await driveApi.files.list(
        q: "name='$_backupFileName' and '$folderId' in parents",
        spaces: 'drive',
      );

      if (fileList.files?.isEmpty ?? true) {
        print('No backup file found in folder');
        return null;
      }

      final fileId = fileList.files!.first.id;
      if (fileId == null) {
        print('No fileId found');
        return null;
      }
      print('Found backup file: $fileId');

      // Download file content
      final drive.Media file = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      print('Reading file content...');
      final List<int> dataBytes = await collectBytes(file.stream);
      final jsonString = utf8.decode(dataBytes);
      final List<dynamic> jsonData = json.decode(jsonString);
      print('Restored data size: ${jsonData.length} items');

      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error in restoreFromGoogleDrive: $e');
      return null;
    }
  }

  Future<List<int>> collectBytes(Stream<List<int>> stream) async {
    print('Collecting bytes from stream...');
    final List<int> bytes = [];
    await for (final List<int> chunk in stream) {
      bytes.addAll(chunk);
    }
    print('Total bytes collected: ${bytes.length}');
    return bytes;
  }

  Future<String?> _findExistingBackup(drive.DriveApi driveApi) async {
    try {
      print('Searching for backup file: $_backupFileName');
      final fileList = await driveApi.files.list(
        q: "name = '$_backupFileName'",
        spaces: 'drive',
      );

      if (fileList.files?.isNotEmpty == true) {
        print('Found existing backup file: ${fileList.files!.first.id}');
        return fileList.files!.first.id;
      }
      print('No existing backup file found');
      return null;
    } catch (e) {
      print('Error in _findExistingBackup: $e');
      return null;
    }
  }
}

class AuthClient extends http.BaseClient {
  final String accessToken;
  final http.Client _client = http.Client();

  AuthClient(this.accessToken) {
    print('Created AuthClient with token: ${accessToken.substring(0, 10)}...');
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    print('Sending authenticated request to: ${request.url}');
    request.headers['Authorization'] = 'Bearer $accessToken';
    return _client.send(request);
  }
}
