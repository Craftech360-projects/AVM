import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:capsaul/backend/database/transcript_segment.dart'; // Add this import
import 'package:capsaul/backend/preferences.dart';
import 'package:capsaul/utils/features/backups.dart';
import 'package:capsaul/utils/memories/process.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class LocalSyncPage extends StatefulWidget {
  const LocalSyncPage({super.key});

  @override
  _LocalSyncPageState createState() => _LocalSyncPageState();
}

// Remove the TranscriptSegment class from here since we're importing it

class _LocalSyncPageState extends State<LocalSyncPage> {
  List<FileSystemEntity> _files = [];
  bool _loading = false;
  final Map<String, String> _taskStatuses = {}; // Task ID -> Status mapping

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    final entities = directory.listSync();
    setState(() {
      _files = entities
          .where((e) => e.path.endsWith('.wav') || e.path.endsWith('.bin'))
          .toList();
    });
  }

  Future<void> _sendFile(File file) async {
    setState(() => _loading = true);
    try {
      // var uri = Uri.parse(
      //     'https://living-alien-polite.ngrok-free.app/v1/sync-local-files');
      var uri = Uri.parse(
              'https://living-alien-polite.ngrok-free.app/v1/sync-local-files')
          .replace(queryParameters: {'pipeline': 'deepgram'});
      var request = http.MultipartRequest('POST', uri);
      print(uri);
      request.headers['uid'] = SharedPreferencesUtil().uid;

      var fileName = file.path.split('/').last;
      var multipartFile = await http.MultipartFile.fromPath('files', file.path,
          filename: fileName);
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        List<String> taskIds = [];
        if (jsonResponse['task_id'] != null) {
          taskIds.add(jsonResponse['task_id']);
        } else if (jsonResponse['task_ids'] != null) {
          taskIds = List<String>.from(jsonResponse['task_ids']);
        }

        if (taskIds.isNotEmpty) {
          setState(() {
            for (var taskId in taskIds) {
              _taskStatuses[taskId] = 'Processing';
            }
          });
          startTaskStatusCheck(taskIds);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'File uploaded successfully. Task IDs: ${taskIds.join(", ")}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File uploaded successfully')),
          );
        }
      } else {
        throw Exception(
            'Upload failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendAllFiles() async {
    setState(() => _loading = true);
    try {
      // var uri = Uri.parse(
      //     'https://living-alien-polite.ngrok-free.app/v1/sync-local-files');
      var uri = Uri.parse(
              'https://living-alien-polite.ngrok-free.app/v1/sync-local-files')
          .replace(queryParameters: {'pipeline': 'deepgram'});
      var request = http.MultipartRequest('POST', uri);
      request.headers['uid'] = SharedPreferencesUtil().uid;

      for (var file in _files) {
        var fileName = file.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath('files', file.path,
              filename: fileName),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        // Ensure taskIds is a List<String>
        List<String> taskIds = [];
        if (jsonResponse['task_id'] is String) {
          taskIds.add(jsonResponse['task_id'] as String); // Single task ID
        } else if (jsonResponse['task_id'] is List) {
          taskIds =
              List<String>.from(jsonResponse['task_id']); // Multiple task IDs
        }

        print(taskIds);
        print(jsonResponse);

        setState(() {
          for (var taskId in taskIds) {
            _taskStatuses[taskId] = 'Processing';
          }
        });

        startTaskStatusCheck(taskIds);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Files uploaded successfully. Task IDs: ${taskIds.join(", ")}',
            ),
          ),
        );
      } else {
        throw Exception(
            'Upload failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<Map<String, dynamic>> checkTaskStatus(String taskId) async {
    print('Checking task status for $taskId');
    var uri = Uri.parse(
        'https://living-alien-polite.ngrok-free.app/v1/status/$taskId');
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      print(response.body);
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> result = jsonDecode(jsonResponse['result']);
      // Extract and format the transcript segments
      final List<String> formattedSegments = result.map((item) {
        return '${item['text']},${item['speaker']},    ${item['start']}, ${item['end']},';
      }).toList();

      // Join the formatted segments into a single string
      final String fullTranscript = formattedSegments.join('\n\n');

      print("create memory");
      // Convert the JSON data to TranscriptSegment objects using the imported class
      final List<TranscriptSegment> segments = result.map((item) {
        return TranscriptSegment.fromJson(item);
      }).toList();

      print("create memory");
      if (mounted) {
        processTranscriptContent(
          context,
          fullTranscript, // Pass empty string as fullTranscript since we're using segments
          segments,
          null,
          retrievedFromCache: true,
          sendMessageToChat: sendMessageToChat,
        ).then((m) {
          if (mounted && m != null && !m.discarded) executeBackupWithUid();
        });
      }

      return jsonResponse;
    } else {
      throw Exception('Failed to fetch task status: ${response.statusCode}');
    }
  }

  Timer? _statusCheckTimer;

  get sendMessageToChat => null;

  void startTaskStatusCheck(List<String> taskIds) {
    print("timer started");
    _statusCheckTimer = Timer.periodic(Duration(seconds: 15), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Create a copy of the taskIds list for iteration
      List<String> taskIdsCopy = List.from(taskIds);

      for (var taskId in taskIdsCopy) {
        try {
          var status = await checkTaskStatus(taskId);
          if (!mounted) {
            timer.cancel();
            return;
          }

          setState(() {
            _taskStatuses[taskId] = status['status'];
          });

          if (status['status'] == 'completed') {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task $taskId completed!')),
              );
            }
            // Remove the taskId from the original list outside of the loop
            //  taskIds.remove(taskId);
          } else if (status['status'] == 'failed') {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Task $taskId failed: ${status['error']}')),
              );
            }
            // Remove the taskId from the original list outside of the loop
            // taskIds.remove(taskId);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error checking task status: $e')),
            );
          }
        }

        if (taskIds.isEmpty) {
          timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _deleteFile(File file) async {
    try {
      await file.delete();
      _loadFiles(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting file: $e')),
      );
    }
  }

  Future<void> _deleteAllFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final entities = directory.listSync();
      final audioFiles = entities
          .where((e) => e.path.endsWith('.wav') || e.path.endsWith('.bin'));
      for (var file in audioFiles) {
        await File(file.path).delete();
      }
      _loadFiles(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting files: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Sync Files'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadFiles,
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete All Files'),
                  content: Text('Are you sure you want to delete all files?'),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text('Delete'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteAllFiles();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ElevatedButton(
                  onPressed: _files.isEmpty ? null : _sendAllFiles,
                  child: Text('Send All Files'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final file = File(_files[index].path);
                      final fileName = file.path.split('/').last;
                      final fileSize = _formatFileSize(file.lengthSync());
                      return ListTile(
                        title: Text(fileName),
                        subtitle: Text('Size: $fileSize'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteFile(file),
                            ),
                            IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () => _sendFile(file),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (_taskStatuses.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Task Status:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ..._taskStatuses.entries.map(
                          (entry) => ListTile(
                            title: Text("Task ID: ${entry.key}"),
                            subtitle: Text("Status: ${entry.value}"),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
