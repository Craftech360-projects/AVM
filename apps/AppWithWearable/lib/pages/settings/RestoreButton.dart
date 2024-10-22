import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class RestoreButton extends StatefulWidget {
  const RestoreButton({super.key});

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
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
          title: const Text(
            'Restore Latest Backup',
            style: TextStyle(color: Colors.white),
          ),
          trailing: const Icon(
            Icons.restore,
            size: 20,
          ),
          onTap: () {
            _restoreBackup();
          },
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 8.0),
        //   child: ElevatedButton.icon(
        //     icon: const Icon(Icons.restore),
        //     label: const Text('Restore Latest Backup'),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.green,
        //       textStyle: const TextStyle(color: Colors.white),
        //     ),
        //     onPressed: _restoreBackup,
        //   ),
        // ),

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
  // void _restoreBackup() async {
  //   setState(() => isRestoreInProgress = true);
  //   try {
  //     await requestStoragePermission();
  //     final directory = await getExternalStorageDirectory();
  //     if (directory == null) {
  //       print('External storage directory not found.');
  //       setState(() => isRestoreInProgress = false);
  //       return;
  //     }
  //     // final backupDirectory = Directory('${directory.path}/Documents/AVM_Backups');
  //     final backupDirectory =
  //         Directory('/storage/emulated/0/Documents/Avm/Backups');

  //     if (!await backupDirectory.exists()) {
  //       print('Backup directory does not exist.');
  //       setState(() => isRestoreInProgress = false);
  //       return;
  //     }

  //     List<FileSystemEntity> files = backupDirectory.listSync();
  //     print('list of files $files');
  //     List<FileSystemEntity> backupFiles =
  //         files.where((file) => file.path.endsWith('.json')).toList();
  //     print('backups file found ${backupFiles}');
  //     if (backupFiles.isEmpty) {
  //       print('No backup files found.');
  //       setState(() => isRestoreInProgress = false);
  //       return;
  //     }
  //     backupFiles.sort((a, b) {
  //       String aTime = a.path.split('backup_')[1].split('.json')[0];
  //       String bTime = b.path.split('backup_')[1].split('.json')[0];
  //       return int.parse(bTime).compareTo(int.parse(aTime));
  //     });

  //     File latestBackup = File(backupFiles.first.path);
  //     print('Restoring from: ${latestBackup.path}');
  //     String content = await latestBackup.readAsString();

  //     String password = SharedPreferencesUtil().uid;
  //     List<dynamic> jsonData = decodeJson(content, password);
  //     for (var memoryData in jsonData) {
  //       Memory memory = Memory.fromJson(memoryData);
  //       MemoryProvider().saveMemory(memory);
  //     }
  //     print('Restore completed successfully.');
  //   } catch (e) {
  //     print('Error during restore: $e');
  //   } finally {
  //     setState(() => isRestoreInProgress = false);
  //   }
  // }
  void _restoreBackup() async {
    setState(() => isRestoreInProgress = true);

    try {
      await requestStoragePermission();
      // Get backup directory
      final directory = Directory('/storage/emulated/0/Documents/Avm/Backups');

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
      SharedPreferencesUtil().isRestoreSuccessful = true;
      print('Restore completed successfully.');
    } catch (e) {
      print('Error during restore: $e');
    } finally {
      setState(() => isRestoreInProgress = false);
    }
  }

  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    print('is permission granted: ${status.isGranted}');

    if (status.isGranted) {
      if (await Permission.manageExternalStorage.isGranted) {
        print('Manage External Storage Permission granted');
        return true;
      } else {
        var manageExternalStorageStatus =
            await Permission.manageExternalStorage.request();
        if (manageExternalStorageStatus.isGranted) {
          print('Manage External Storage Permission granted');
          return true;
        } else {
          print('Manage External Storage Permission denied');
          return false;
        }
      }
    } else if (status.isDenied) {
      status = await Permission.storage.request();

      if (status.isGranted) {
        if (await Permission.manageExternalStorage.isGranted) {
          print('Manage External Storage Permission granted');
          return true;
        } else {
          var manageExternalStorageStatus =
              await Permission.manageExternalStorage.request();
          if (manageExternalStorageStatus.isGranted) {
            print('Manage External Storage Permission granted');
            return true;
          } else {
            print('Manage External Storage Permission denied');
            return false;
          }
        }
      } else {
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
          title: const Text("Permission Required"),
          content: const Text(
              "Storage permission is required to access files. Please enable it in the app settings."),
          actions: <Widget>[
            TextButton(
              child: const Text("Settings"),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
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
