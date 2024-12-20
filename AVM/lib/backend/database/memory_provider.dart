import 'dart:convert';
import 'dart:io';

import 'package:avm/backend/database/box.dart';
import 'package:avm/backend/database/memory.dart';
import 'package:avm/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';

class MemoryProvider {
  static final MemoryProvider _instance = MemoryProvider._internal();
  static final Box<Memory> _box = ObjectBoxUtil().box!.store.box<Memory>();
  static final Box<Structured> _boxStructured =
      ObjectBoxUtil().box!.store.box<Structured>();
  static final Box<Event> _boxEvent = ObjectBoxUtil().box!.store.box<Event>();
  static final Box<ActionItem> _boxActionItem =
      ObjectBoxUtil().box!.store.box<ActionItem>();

  factory MemoryProvider() {
    return _instance;
  }

  MemoryProvider._internal();

//* Action Items Method
// -----------------------

  int updateActionItem(ActionItem item) => _boxActionItem.put(item);

// -----------------------

  // Method to get the Memory box

//-------------
  List<Memory> getMemories() => _box.getAll();
  int getMemoriesCount() => _box.count();

  int getNonDiscardedMemoriesCount() =>
      _box.query(Memory_.discarded.equals(false)).build().count();

  List<Memory> getMemoriesOrdered({bool includeDiscarded = false}) {
    if (includeDiscarded) {
      // created at descending
      // The method retrieves all Memory objects from the store, regardless of whether they are discarded or not.
      return _box.query().order(Memory_.createdAt).build().find();
    } else {
      return _box
          .query(Memory_.discarded.equals(false))
          .order(Memory_.createdAt, flags: Order.descending)
          .build()
          .find();
    }
  }

  setEventCreated(Event event) {
    event.created = true;
    _boxEvent.put(event);
  }

  // Save Memory
  int saveMemory(Memory memory) {
    try {
      // Debugging output

      // Ensure geolocation target is set if available
      if (memory.geolocation.target != null) {
      } else {
      }

      // Save the memory
      int id = _box.put(memory);


      Memory? fetchedMemory = MemoryProvider().getMemoryById(id);

      if (fetchedMemory == null) {
        return id;
      }

      // Step 3: Check if geolocation data is present
      if (fetchedMemory.geolocation.target != null) {
      } else {
      }
      return id;
    } catch (e) {
      return -1; // Return an error indicator
    }
  }

  bool deleteMemory(Memory memory) => _box.remove(memory.id);

  int updateMemory(Memory memory) => _box.put(memory);

  int updateMemoryStructured(Structured structured) =>
      _boxStructured.put(structured);

  Memory? getMemoryById(int id) => _box.get(id);

  List<int> storeMemories(List<Memory> memories) => _box.putMany(memories);

  int removeAllMemories() => _box.removeAll();

  List<Memory> getMemoriesById(List<int> ids) {
    List<Memory?> memories = _box.getMany(ids);
    return memories.whereType<Memory>().toList();
  }

  List<Memory> retrieveRecentMemoriesWithinMinutes(
      {int minutes = 10, int count = 2}) {
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
     Geolocation: ${memory.geolocation.target != null ? memory.geolocation.target.toString() : 'None'}}
    ''';
  }

  //void addMemory(Memory fromJson) {}
}

String getPrettyJSONString(jsonObject) {
  var encoder = const JsonEncoder.withIndent("     ");
  return encoder.convert(jsonObject);
}


// Add your method to convert Memory to string representation for debugging
  