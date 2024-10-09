import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RestoreButton extends StatefulWidget {
  const RestoreButton({Key? key}) : super(key: key);

  @override
  _RestoreButtonState createState() => _RestoreButtonState();
}

class _RestoreButtonState extends State<RestoreButton> {
  bool isRestoreInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Restore Backup Button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.restore),
            label: const Text('Restore Latest Backup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              textStyle: const TextStyle(color: Colors.white),
            ),
            onPressed: _restoreBackup,
          ),
        ),

        if (isRestoreInProgress)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Restoring backup...',
                style: TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }

  // Restore backup function
  void _restoreBackup() async {
    setState(() => isRestoreInProgress = true);

    try {
      // Get backup directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        print('Backup directory not found.');
        setState(() => isRestoreInProgress = false);
        return;
      }

      // Get the list of files in the directory
      List<FileSystemEntity> files = Directory(directory.path).listSync();
      List<FileSystemEntity> backupFiles =
          files.where((file) => file.path.endsWith('.json')).toList();

      // Sort files by timestamp and get the latest one
      if (backupFiles.isEmpty) {
        print('No backup files found.');
        setState(() => isRestoreInProgress = false);
        return;
      }

      backupFiles.sort((a, b) {
        String aTime = a.path.split('backup_')[1].split('.json')[0];
        String bTime = b.path.split('backup_')[1].split('.json')[0];
        return int.parse(bTime).compareTo(int.parse(aTime));
      });

      File latestBackup = File(backupFiles.first.path);
      print(latestBackup);
      // Read the latest backup
      String content = await latestBackup.readAsString();
   
      List<dynamic> jsonData = jsonDecode(content);
     
      for (var memory in jsonData) {
      
        MemoryProvider().saveMemory(Memory.fromJson(memory));
      }

      print('Restore completed successfully.');
    } catch (e) {
      print('Error during restore: $e');
    } finally {
      setState(() => isRestoreInProgress = false);
    }
  }

  // Request storage permission (using the same method you provided)

  Future<bool> requestStoragePermission(BuildContext context) async {
    var status = await Permission.storage.status;
    print(status.isGranted);
    if (status.isGranted) {
      // Permission is already granted
      return true;
    } else if (status.isDenied) {
      // Request permission
      status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      } else {
        // Permission is permanently denied, guide the user to settings
        _showPermissionDeniedDialog(context);
        return false;
      }
    }
    return false;
  }

  // Show a dialog if permission is denied
  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Required"),
          content: Text(
              "Storage permission is required to access files. Please enable it in the app settings."),
          actions: <Widget>[
            TextButton(
              child: Text("Settings"),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
