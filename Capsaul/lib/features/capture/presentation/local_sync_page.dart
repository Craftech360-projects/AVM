// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

// class LocalSyncPage extends StatefulWidget {
//   const LocalSyncPage({super.key});

//   @override
//   _LocalSyncPageState createState() => _LocalSyncPageState();
// }

// class _LocalSyncPageState extends State<LocalSyncPage> {
//   List<FileSystemEntity> _files = [];
//   bool _loading = false;

//   String _formatFileSize(int bytes) {
//     if (bytes < 1024) return '$bytes B';
//     if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
//     if (bytes < 1024 * 1024 * 1024)
//       return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
//     return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
//   }

//   String _getFileDateTime(String fileName) {
//     try {
//       if (fileName == 'continuous_audio_backup.bin') {
//         return 'Continuous Recording';
//       }
//       final timeStamp = fileName.split('_').last.replaceAll('.bin', '');
//       final dateTime =
//           DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp) * 1000);
//       return dateTime.toString();
//     } catch (e) {
//       return 'Unknown Date';
//     }
//   }

//   String _getTimeFromFileName(String fileName) {
//     try {
//       final parts = fileName.split('_');
//       if (parts.length < 2) return 'Unknown time';

//       // Extract timestamp from filename like audio_1234567890_abcd1234.bin
//       final timestampStr = parts[1];
//       final timestamp = int.tryParse(timestampStr);
//       if (timestamp == null) return 'Invalid timestamp';

//       final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//       return dateTime.toString();
//     } catch (e) {
//       return 'Unknown time';
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadFiles();
//   }

//   Future<void> _loadFiles() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final entities = directory.listSync();
//     setState(() {
//       _files = entities.where((e) => e.path.endsWith('.bin')).toList();
//     });
//   }

//   Future<void> _sendFile(File file) async {
//     setState(() => _loading = true);

//     try {
//       var uri = Uri.parse(
//           'https://living-alien-polite.ngrok-free.app/v1/sync-local-files');
//       var request = http.MultipartRequest('POST', uri);

//       // Add uid header
//       request.headers['uid'] = 'user123'; // Replace with actual user ID

//       // Add file with proper name formatting
//       var fileName = file.path.split('/').last;
//       var multipartFile = await http.MultipartFile.fromPath(
//           'files', // server expects 'files' as the field name
//           file.path,
//           filename: fileName // preserve original filename
//           );
//       request.files.add(multipartFile);

//       // Send the request
//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('File uploaded successfully')),
//           );
//         }
//       } else {
//         throw Exception(
//             'Upload failed: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//       debugPrint('Upload error: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _loading = false);
//       }
//     }
//   }

//   Future<void> _deleteFile(File file) async {
//     try {
//       await file.delete();
//       _loadFiles(); // Refresh the list
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('File deleted')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error deleting file: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _deleteAllFiles() async {
//     try {
//       setState(() => _loading = true);
//       final directory = await getApplicationDocumentsDirectory();
//       final entities = directory.listSync();
//       final binFiles = entities.where((e) => e.path.endsWith('.bin'));

//       for (var file in binFiles) {
//         await File(file.path).delete();
//       }

//       await _loadFiles(); // Refresh the list
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('All files deleted')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error deleting files: $e')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _loading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Local Sync Files'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _loadFiles,
//           ),
//           IconButton(
//             icon: Icon(Icons.delete_forever),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: Text('Delete All Files'),
//                   content: Text('Are you sure you want to delete all files?'),
//                   actions: [
//                     TextButton(
//                       child: Text('Cancel'),
//                       onPressed: () => Navigator.of(context).pop(),
//                     ),
//                     TextButton(
//                       child: Text('Delete'),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                         _deleteAllFiles();
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: _loading
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: _files.length,
//               itemBuilder: (context, index) {
//                 final file = File(_files[index].path);
//                 final fileName = file.path.split('/').last;
//                 final fileSize = _formatFileSize(file.lengthSync());
//                 final fileDate = _getTimeFromFileName(fileName);

//                 return ListTile(
//                   title: Text(fileName),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Size: $fileSize'),
//                       Text('Time: $fileDate'),
//                     ],
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.delete, color: Colors.red),
//                         onPressed: () => _deleteFile(file),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.send),
//                         onPressed: () => _sendFile(file),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'dart:io';

import 'package:capsaul/backend/preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class LocalSyncPage extends StatefulWidget {
  const LocalSyncPage({super.key});

  @override
  _LocalSyncPageState createState() => _LocalSyncPageState();
}

class _LocalSyncPageState extends State<LocalSyncPage> {
  List<FileSystemEntity> _files = [];
  bool _loading = false;

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
    final entities = directory.listSync();
    setState(() {
      _files = entities.where((e) => e.path.endsWith('.bin')).toList();
    });
  }

  Future<void> _sendFile(File file) async {
    setState(() => _loading = true);

    try {
      var uri = Uri.parse(
          'https://living-alien-polite.ngrok-free.app/v1/sync-local-files');
      var request = http.MultipartRequest('POST', uri);

      // Add uid header
      request.headers['uid'] =
          SharedPreferencesUtil().uid; // Replace with actual user ID

      var fileName = file.path.split('/').last;
      var multipartFile = await http.MultipartFile.fromPath('files', file.path,
          filename: fileName);
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File uploaded successfully')),
          );
        }
      } else {
        throw Exception(
            'Upload failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Future<void> _sendAllFiles() async {
  //   setState(() => _loading = true);
  //   try {
  //     for (var entity in _files) {
  //       var file = File(entity.path);
  //       await _sendFile(file);
  //     }
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('All files uploaded successfully')),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error sending files: $e')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() => _loading = false);
  //     }
  //   }
  // }

  Future<void> _sendAllFiles() async {
    setState(() => _loading = true);
    try {
      var uri = Uri.parse(
          'https://living-alien-polite.ngrok-free.app/v1/sync-local-files'); // Update with your API endpoint
      var request = http.MultipartRequest('POST', uri);
      request.headers['uid'] = SharedPreferencesUtil().uid;
      // Add all files to the request
      for (var file in _files) {
        var fileName = file.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath('files', file.path,
              filename: fileName),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('All files uploaded successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to upload files: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending files: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
              ],
            ),
    );
  }

  Future<void> _deleteFile(File file) async {
    try {
      await file.delete();
      _loadFiles(); // Refresh the list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting file: $e')),
        );
      }
    }
  }

  Future<void> _deleteAllFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final entities = directory.listSync();
      final binFiles = entities.where((e) => e.path.endsWith('.bin'));

      for (var file in binFiles) {
        await File(file.path).delete();
      }
      _loadFiles(); // Refresh the list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting files: $e')),
        );
      }
    }
  }
}
