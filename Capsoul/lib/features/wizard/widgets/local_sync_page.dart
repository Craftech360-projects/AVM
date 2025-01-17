// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

// class LocalSyncPage extends StatefulWidget {
//   const LocalSyncPage({Key? key}) : super(key: key);

//   @override
//   State<LocalSyncPage> createState() => _LocalSyncPageState();
// }

// class _LocalSyncPageState extends State<LocalSyncPage> {
//   List<FileSystemEntity> _files = [];
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadFiles();
//   }

//   Future<void> _loadFiles() async {
//     setState(() {
//       _loading = true;
//     });

//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final syncDirectory = Directory(directory.path);

//       if (await syncDirectory.exists()) {
//         final files =
//             syncDirectory.listSync().where((file) => file is File).toList();
//         setState(() {
//           _files = files;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading files: $e');
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Local Sync Files'),
//         backgroundColor: Colors.purple,
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : _files.isEmpty
//               ? const Center(child: Text('No files found.'))
//               : ListView.builder(
//                   itemCount: _files.length,
//                   itemBuilder: (context, index) {
//                     final file = _files[index];
//                     return ListTile(
//                       title: Text(file.path.split('/').last),
//                       subtitle: Text(
//                           '${(file.statSync().size / 1024).toStringAsFixed(2)} KB'),
//                       trailing: IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () async {
//                           try {
//                             await file.delete();
//                             _loadFiles();
//                           } catch (e) {
//                             debugPrint('Error deleting file: $e');
//                           }
//                         },
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }

import 'dart:io';

import 'package:capsoul/utils/audio/deepgram.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LocalSyncPage extends StatefulWidget {
  const LocalSyncPage({super.key});

  @override
  State<LocalSyncPage> createState() => _LocalSyncPageState();
}

class _LocalSyncPageState extends State<LocalSyncPage> {
  late List<File> _wals;
  late Map<DateTime, List<File>> _groupedWals;
  bool _loading = true;
  final _syncStatus = <String, double>{}; // Tracks progress of each WAL file

  @override
  void initState() {
    super.initState();
    _loadWals();
  }

  /// Load WAL files and group them by date
  // Future<void> _loadWals() async {
  //   setState(() {
  //     _loading = true;
  //   });

  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final syncDirectory = Directory(directory.path);

  //     if (await syncDirectory.exists()) {
  //       final files =
  //           syncDirectory.listSync().where((file) => file is File).toList();
  //       // setState(() {
  //       //   _files = files;
  //       // });

  //       setState(() {
  //         _wals = files;
  //         _groupedWals = _groupWalsByDate(_wals);
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('Error loading WALs: $e');
  //   } finally {
  //     setState(() {
  //       _loading = false;
  //     });
  //   }
  // }

  Future<void> _loadWals() async {
    setState(() {
      _loading = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final syncDirectory = Directory(directory.path);

      if (await syncDirectory.exists()) {
        // Use whereType<File>() to ensure only File objects are included
        final files = syncDirectory.listSync().whereType<File>().toList();
        setState(() {
          _wals = files;
          _groupedWals = _groupWalsByDate(_wals);
        });
      }
    } catch (e) {
      debugPrint('Error loading WALs: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// Group WALs by date
  Map<DateTime, List<File>> _groupWalsByDate(List<File> wals) {
    final groupedWals = <DateTime, List<File>>{};
    for (final file in wals) {
      final modified = file.lastModifiedSync();
      final date =
          DateTime(modified.year, modified.month, modified.day, modified.hour);
      groupedWals.putIfAbsent(date, () => []).add(file);
    }
    return groupedWals;
  }

  /// Simulate syncing a WAL file to the backend
  Future<void> _syncWal(File wal) async {
    print("here , single");
    final id = wal.path; // Use file path as a unique ID
    _syncStatus[id] = 0.0;

    // for (int i = 0; i <= 100; i += 10) {
    //   await Future.delayed(const Duration(milliseconds: 200));
    //   setState(() {
    //     _syncStatus[id] = i / 100;
    //   });
    // }

    await transcribeWithDeepgram(wal.path);

    setState(() {
      _syncStatus[id] = 1.0; // Mark as fully synced
    });

    // Simulate removing the file after successful sync
    //await wal.delete();
    _loadWals();
  }

  /// Sync all WAL files
  Future<void> _syncAll() async {
    for (final file in _wals) {
      await _syncWal(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Sync'),
        backgroundColor: Colors.purple,
        actions: [
          if (_wals.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _syncAll,
              tooltip: 'Sync All',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _groupedWals.isEmpty
              ? const Center(child: Text('No WALs found.'))
              : ListView.builder(
                  itemCount: _groupedWals.keys.length,
                  itemBuilder: (context, index) {
                    final date = _groupedWals.keys.toList()[index];
                    final wals = _groupedWals[date]!;
                    return _buildDateGroup(date, wals);
                  },
                ),
    );
  }

  /// Build a group of WALs for a specific date
  Widget _buildDateGroup(DateTime date, List<File> wals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            _formatDate(date),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ...wals.map((wal) => _buildWalItem(wal)),
      ],
    );
  }

  /// Build a single WAL item
  Widget _buildWalItem(File wal) {
    final id = wal.path;
    final syncProgress = _syncStatus[id] ?? 0.0;

    return ListTile(
      leading: const Icon(Icons.file_copy, color: Colors.blue),
      title: Text(wal.path.split('/').last),
      subtitle: Text(
        syncProgress == 1.0
            ? 'Synced'
            : 'Size: ${(wal.lengthSync() / 1024).toStringAsFixed(2)} KB',
      ),
      trailing: syncProgress > 0 && syncProgress < 1.0
          ? SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: syncProgress,
                backgroundColor: Colors.grey.shade300,
                color: Colors.blue,
              ),
            )
          : IconButton(
              icon: const Icon(Icons.sync, color: Colors.blue),
              onPressed: () => _syncWal(wal),
              tooltip: 'Sync',
            ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
        "${date.hour.toString().padLeft(2, '0')}:00";
  }
}
