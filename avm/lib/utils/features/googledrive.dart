import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleDriveService {
  static const _scope = 'https://www.googleapis.com/auth/drive.file';
  static const _backupFileName = 'memories_backup.json';

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [_scope]);

  Future<drive.DriveApi?> _getDriveApi() async {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? auth = await account?.authentication;

    if (auth?.accessToken == null) {
      print('Failed to get Google Drive access token');
      return null;
    }

    final authenticatedClient = AuthClient(auth!.accessToken!);
    return drive.DriveApi(authenticatedClient);
  }

  Future<bool> uploadBackupToGoogleDrive(
      List<Map<String, dynamic>> data) async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return false;

      // Convert data to JSON string
      final jsonString = json.encode(data);
      final List<int> dataBytes = utf8.encode(jsonString);

      // Create file metadata
      var driveFile = drive.File()..name = _backupFileName;

      // Check if backup file already exists
      String? existingFileId = await _findExistingBackup(driveApi);

      if (existingFileId != null) {
        // Update existing file
        await driveApi.files.update(
          driveFile,
          existingFileId,
          uploadMedia:
              drive.Media(Stream.fromIterable([dataBytes]), dataBytes.length),
        );
        print('Backup file updated successfully');
      } else {
        // Create new file
        await driveApi.files.create(
          driveFile,
          uploadMedia:
              drive.Media(Stream.fromIterable([dataBytes]), dataBytes.length),
        );
        print('New backup file created successfully');
      }

      return true;
    } catch (e) {
      print('Error uploading to Google Drive: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> restoreFromGoogleDrive() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return null;

      String? fileId = await _findExistingBackup(driveApi);
      if (fileId == null) {
        print('No backup file found');
        return null;
      }

      // Get the file content
      final drive.Media file = await driveApi.files.get(fileId,
          downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

      // Collect all bytes from the stream
      final List<int> dataBytes = await collectBytes(file.stream);
      final jsonString = utf8.decode(dataBytes);
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error restoring from Google Drive: $e');
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
    } catch (e) {
      print('Error finding existing backup: $e');
      return null;
    }
  }
}

// Custom AuthClient to handle Google Drive API requests
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
