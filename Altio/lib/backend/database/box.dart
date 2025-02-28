// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';

// import '../../objectbox.g.dart';

// class ObjectBox {
//   /// The Store of this app.
//   late final Store store;

//   ObjectBox._create(this.store) {
//     // Add any additional setup code, e.g. build queries.
//   }

//   /// Create an instance of ObjectBox to use throughout the app.
//   static Future<ObjectBox> create() async {
//     final docsDir = await getApplicationDocumentsDirectory();
//     // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
//     final store = await openStore(directory: p.join(docsDir.path, "obx-example"));
//     return ObjectBox._create(store);
//   }
// }

// class ObjectBoxUtil {
//   static final ObjectBoxUtil _instance = ObjectBoxUtil._internal();
//   static ObjectBox? _box;

//   factory ObjectBoxUtil() {
//     return _instance;
//   }

//   ObjectBoxUtil._internal();

//   static Future<void> init() async {
//     _box = await ObjectBox.create();
//   }

//   ObjectBox? get box => _box;
// }

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../objectbox.g.dart';

class ObjectBox {
  /// The Store of this app.
  final Store store; // Changed to final for clarity

  ObjectBox._create(this.store) {
    // Add any additional setup code, e.g., build queries.
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store =
        await openStore(directory: p.join(docsDir.path, "obx-example"));
    return ObjectBox._create(store);
  }
}

class ObjectBoxUtil {
  static final ObjectBoxUtil _instance = ObjectBoxUtil._internal();
  static ObjectBox? _box;

  factory ObjectBoxUtil() {
    return _instance;
  }

  ObjectBoxUtil._internal();

  static Future<void> init() async {
    _box ??= await ObjectBox.create();
  }

  // Expose the singleton instance
  static ObjectBox get instance {
    if (_box == null) {
      throw StateError(
          "ObjectBoxUtil must be initialized before accessing instance.");
    }
    return _box!;
  }

  // Optional: Check if initialized
  static bool get isInitialized => _box != null;

  // Backward compatibility with existing code (e.g., MessageProvider, MemoryProvider)
  ObjectBox? get box => _box;
}
