// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

// import 'package:altio/backend/database/box.dart';
// import 'package:altio/backend/database/memory.dart';
// import 'package:altio/objectbox.g.dart';
// import 'package:path_provider/path_provider.dart';

// class MemoryProvider {
//   static final MemoryProvider _instance = MemoryProvider._internal();
//   static final Box<Memory> _box = ObjectBoxUtil().box!.store.box<Memory>();
//   // static final Box<Structured> _boxStructured =
//   //     ObjectBoxUtil().box!.store.box<Structured>();
//   static final Box<Event> _boxEvent = ObjectBoxUtil().box!.store.box<Event>();
//   static final Box<ActionItem> _boxActionItem =
//       ObjectBoxUtil().box!.store.box<ActionItem>();

//   factory MemoryProvider() {
//     return _instance;
//   }

//   MemoryProvider._internal();

// // Action Items Method
//   int updateActionItem(ActionItem item) => _boxActionItem.put(item);

//   List<ActionItem> getAllActionItems() {
//     return _boxActionItem.getAll();
//   }

//   List<ActionItem> getActionItemsOrdered() {
//     return _boxActionItem
//         .query()
//         .order(ActionItem_.createdAt, flags: Order.descending)
//         .build()
//         .find();
//   }

//   List<ActionItem> getActionItemsByStatus(bool completed) {
//     return _boxActionItem
//         .query(ActionItem_.completed.equals(completed))
//         .build()
//         .find();
//   }

//   // Method to get the Memory box
//   List<Memory> getMemories() => _box.getAll();
//   int getMemoriesCount() => _box.count();

//   int getNonDiscardedMemoriesCount() =>
//       _box.query(Memory_.discarded.equals(false)).build().count();

//   List<Memory> getMemoriesOrdered({bool includeDiscarded = false}) {
//     if (includeDiscarded) {
//       return _box.query().order(Memory_.createdAt).build().find();
//     } else {
//       return _box
//           .query(Memory_.discarded.equals(false))
//           .order(Memory_.createdAt, flags: Order.descending)
//           .build()
//           .find();
//     }
//   }

//   void setEventCreated(Event event) {
//     event.created = true;
//     _boxEvent.put(event);
//   }

//   // Save Memory
//   int saveMemory(Memory memory) {
//     try {
//       // Debugging output

//       // Ensure geolocation target is set if available
//       if (memory.geolocation.target != null) {
//       } else {}

//       // Save the memory
//       int id = _box.put(memory);

//       Memory? fetchedMemory = MemoryProvider().getMemoryById(id);

//       if (fetchedMemory == null) {
//         return id;
//       }

//       // Step 3: Check if geolocation data is present
//       if (fetchedMemory.geolocation.target != null) {
//       } else {}
//       return id;
//     } on Exception catch (e) {
//       log(e.toString());
//       return -1; // Return an error indicator
//     }
//   }

//   // DeleteMemory
//   Future<bool> deleteMemory(Memory memory) async {
//     try {
//       return _box.remove(memory.id);
//     } on Exception catch (e) {
//       log('Error deleting memory: $e');
//       return false;
//     }
//   }

// // Add a new method for batch deletion
//   Future<bool> batchDeleteMemories(List<Memory> memories) async {
//     try {
//       final ids = memories.map((m) => m.id).toList();
//       _box.removeMany(ids);
//       return true;
//     } on Exception catch (e) {
//       log('Error in batchDeleteMemories: $e');
//       return false;
//     }
//   }

//   Future<void> updateMemory(Memory memory) async {
//     final box = ObjectBoxUtil().box!.store.box<Memory>();
//     box.put(memory);
//   } // ---> Updated function

//   Future<void> updateMemoryStructured(Structured structured) async {
//     final box = ObjectBoxUtil().box!.store.box<Structured>();
//     box.put(structured);
//   } // ---> Updated function

//   Memory? getMemoryById(int id) => _box.get(id);

//   List<int> storeMemories(List<Memory> memories) => _box.putMany(memories);

//   int removeAllMemories() => _box.removeAll();

//   List<Memory> getMemoriesById(List<int> ids) {
//     List<Memory?> memories = _box.getMany(ids);
//     return memories.whereType<Memory>().toList();
//   }

//   List<Memory> retrieveRecentMemoriesWithinMinutes(
//       {int minutes = 10, int count = 2}) {
//     DateTime timeLimit = DateTime.now().subtract(Duration(minutes: minutes));
//     var query = _box
//         .query(Memory_.createdAt.greaterThan(timeLimit.millisecondsSinceEpoch))
//         .build();
//     List<Memory> filtered = query.find();
//     query.close();

//     if (filtered.length > count) filtered = filtered.sublist(0, count);
//     return filtered;
//   }

//   List<Memory> retrieveDayMemories(DateTime day) {
//     DateTime start = DateTime(day.year, day.month, day.day);
//     DateTime end = DateTime(day.year, day.month, day.day, 23, 59, 59);
//     var query = _box
//         .query(Memory_.createdAt
//             .between(start.millisecondsSinceEpoch, end.millisecondsSinceEpoch)
//             .and(Memory_.discarded.equals(false)))
//         .build();
//     List<Memory> filtered = query.find();
//     query.close();
//     return filtered;
//   }

//   List<Memory> retrieveMemoriesWithinDates(DateTime start, DateTime end) {
//     var query = _box
//         .query(Memory_.createdAt
//             .between(start.millisecondsSinceEpoch, end.millisecondsSinceEpoch)
//             .and(Memory_.discarded.equals(false)))
//         .build();
//     List<Memory> filtered = query.find();
//     query.close();
//     return filtered;
//   }

//   Future<File> exportMemoriesToFile() async {
//     String json =
//         getPrettyJSONString(getMemories().map((m) => m.toJson()).toList());
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/memories.json');
//     await file.writeAsString(json);
//     return file;
//   }

//   static String memoryToString(Memory memory) {
//     return '''
//     Memory ID: ${memory.id}
//     Created At: ${memory.createdAt}
//     Transcript: ${memory.transcript}
//     Discarded: ${memory.discarded}
//      Geolocation: ${memory.geolocation.target != null ? memory.geolocation.target.toString() : 'None'}}
//     ''';
//   }
// }

// String getPrettyJSONString(dynamic jsonObject) {
//   var encoder = const JsonEncoder.withIndent("     ");
//   return encoder.convert(jsonObject);
// }

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:altio/backend/database/box.dart';
import 'package:altio/backend/database/memory.dart'; // Ensure this includes Structured
import 'package:altio/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';

class MemoryProvider {
  static final MemoryProvider _instance = MemoryProvider._internal();
  final Box<Memory> _box;
  final Box<Event> _boxEvent;
  final Box<ActionItem> _boxActionItem;
  final Box<Structured> _boxStructured; // Add this for Structured entities

  // Singleton for main app (uses ObjectBoxUtil)
  factory MemoryProvider() {
    return _instance;
  }

  // Private constructor for singleton
  MemoryProvider._internal()
      : _box = ObjectBoxUtil.instance.store.box<Memory>(),
        _boxEvent = ObjectBoxUtil.instance.store.box<Event>(),
        _boxActionItem = ObjectBoxUtil.instance.store.box<ActionItem>(),
        _boxStructured = ObjectBoxUtil.instance.store.box<Structured>();

  // Constructor for Workmanager isolate
  MemoryProvider.withStore(Store store)
      : _box = store.box<Memory>(),
        _boxEvent = store.box<Event>(),
        _boxActionItem = store.box<ActionItem>(),
        _boxStructured = store.box<Structured>();

  // Action Items Methods
  int updateActionItem(ActionItem item) => _boxActionItem.put(item);

  List<ActionItem> getAllActionItems() => _boxActionItem.getAll();

  List<ActionItem> getActionItemsOrdered() {
    return _boxActionItem
        .query()
        .order(ActionItem_.createdAt, flags: Order.descending)
        .build()
        .find();
  }

  List<ActionItem> getActionItemsByStatus(bool completed) {
    return _boxActionItem
        .query(ActionItem_.completed.equals(completed))
        .build()
        .find();
  }

  // Memory Methods
  List<Memory> getMemories() => _box.getAll();

  int getMemoriesCount() => _box.count();

  int getNonDiscardedMemoriesCount() =>
      _box.query(Memory_.discarded.equals(false)).build().count();

  List<Memory> getMemoriesOrdered({bool includeDiscarded = false}) {
    if (includeDiscarded) {
      return _box.query().order(Memory_.createdAt).build().find();
    } else {
      return _box
          .query(Memory_.discarded.equals(false))
          .order(Memory_.createdAt, flags: Order.descending)
          .build()
          .find();
    }
  }

  void setEventCreated(Event event) {
    event.created = true;
    _boxEvent.put(event);
  }

  int saveMemory(Memory memory) {
    try {
      int id = _box.put(memory);
      Memory? fetchedMemory = getMemoryById(id);
      return fetchedMemory != null ? id : -1;
    } on Exception catch (e) {
      log(e.toString());
      return -1;
    }
  }

  Future<bool> deleteMemory(Memory memory) async {
    try {
      return _box.remove(memory.id);
    } on Exception catch (e) {
      log('Error deleting memory: $e');
      return false;
    }
  }

  Future<bool> batchDeleteMemories(List<Memory> memories) async {
    try {
      final ids = memories.map((m) => m.id).toList();
      _box.removeMany(ids);
      return true;
    } on Exception catch (e) {
      log('Error in batchDeleteMemories: $e');
      return false;
    }
  }

  Future<void> updateMemory(Memory memory) async {
    _box.put(memory);
  }

  // Reintroduced updateMemoryStructured
  Future<void> updateMemoryStructured(Structured structured) async {
    _boxStructured.put(structured);
  }

  Memory? getMemoryById(int id) => _box.get(id);

  List<int> storeMemories(List<Memory> memories) => _box.putMany(memories);

  int removeAllMemories() => _box.removeAll();

  List<Memory> getMemoriesById(List<int> ids) {
    List<Memory?> memories = _box.getMany(ids);
    return memories.whereType<Memory>().toList();
  }

  List<Memory> retrieveRecentMemoriesWithinMinutes({
    int minutes = 10,
    int count = 2,
  }) {
    DateTime timeLimit = DateTime.now().subtract(Duration(minutes: minutes));
    var query = _box
        .query(Memory_.createdAt.greaterThan(timeLimit.millisecondsSinceEpoch))
        .build();
    List<Memory> filtered = query.find();
    query.close();
    if (filtered.length > count) filtered = filtered.sublist(0, count);
    return filtered;
  }

  List<Memory> retrieveDayMemories(DateTime day) {
    DateTime start = DateTime(day.year, day.month, day.day);
    DateTime end = DateTime(day.year, day.month, day.day, 23, 59, 59);
    var query = _box
        .query(Memory_.createdAt
            .between(start.millisecondsSinceEpoch, end.millisecondsSinceEpoch)
            .and(Memory_.discarded.equals(false)))
        .build();
    List<Memory> filtered = query.find();
    query.close();
    return filtered;
  }

  List<Memory> retrieveMemoriesWithinDates(DateTime start, DateTime end) {
    var query = _box
        .query(Memory_.createdAt
            .between(start.millisecondsSinceEpoch, end.millisecondsSinceEpoch)
            .and(Memory_.discarded.equals(false)))
        .build();
    List<Memory> filtered = query.find();
    query.close();
    return filtered;
  }

  Future<File> exportMemoriesToFile() async {
    String json =
        getPrettyJSONString(getMemories().map((m) => m.toJson()).toList());
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/memories.json');
    await file.writeAsString(json);
    return file;
  }

  static String memoryToString(Memory memory) {
    return '''
    Memory ID: ${memory.id}
    Created At: ${memory.createdAt}
    Transcript: ${memory.transcript}
    Discarded: ${memory.discarded}
    Geolocation: ${memory.geolocation.target != null ? memory.geolocation.target.toString() : 'None'}
    ''';
  }
}

String getPrettyJSONString(dynamic jsonObject) {
  var encoder = const JsonEncoder.withIndent("     ");
  return encoder.convert(jsonObject);
}