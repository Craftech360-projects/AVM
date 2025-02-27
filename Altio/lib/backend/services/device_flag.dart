// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';

// class DeviceFlagService {
//   // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final CollectionReference _usersCollection =
//       FirebaseFirestore.instance.collection('users');

//   /// Sets (or inserts) the device flag for the given user.
//   /// If the document already exists, merge with existing data.
//   Future<void> setDeviceFlag({
//     required String uid,
//     required bool hasDevice,
//   }) async {
//     await _usersCollection.doc(uid).set({
//       'hasDevice': hasDevice,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   /// Fetches the device flag for the given user.
//   /// Returns `true`/`false` if the flag exists, or `null` if not found.
//   Future<bool?> fetchDeviceFlag({required String uid}) async {
//     DocumentSnapshot doc = await _usersCollection.doc(uid).get();
//     if (doc.exists) {
//       final data = doc.data() as Map<String, dynamic>?;
//       return data?['hasDevice'] as bool?;
//     }
//     return null;
//   }

//   /// Updates the device flag for the given user.
//   Future<void> updateDeviceFlag({
//     required String uid,
//     required bool hasDevice,
//   }) async {
//     await _usersCollection.doc(uid).update({
//       'hasDevice': hasDevice,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }
// }

// class DeviceProvider with ChangeNotifier {
//   bool? _hasDevice;
//   bool? get hasDevice => _hasDevice;

//   DeviceProvider(String uid) {
//     // Subscribe to real-time updates for the user document.
//     FirebaseFirestore.instance.collection('users').doc(uid).snapshots().listen((docSnapshot) {
//       if (docSnapshot.exists) {
//         final data = docSnapshot.data();
//         bool newValue = data?['hasDevice'] as bool? ?? false;
//         // Update only if there’s a change.
//         if (newValue != _hasDevice) {
//           _hasDevice = newValue;
//           notifyListeners();
//         }
//       }
//     });
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DeviceFlagService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  /// Sets (or inserts) the device flag for the given user.
  /// If the document doesn't exist, it creates a new user document.
  Future<void> setDeviceFlag({
    required String uid,
    required bool hasDevice,
  }) async {
    // Check if the user document exists
    final docSnapshot = await _usersCollection.doc(uid).get();

    if (!docSnapshot.exists) {
      // Create a new user document with default values
      await _usersCollection.doc(uid).set({
        'user_id': uid,
        'hasDevice': hasDevice,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update the existing document with the new device flag
      await _usersCollection.doc(uid).set({
        'hasDevice': hasDevice,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  /// Fetches the device flag for the given user.
  /// If the document doesn't exist, it creates a new user document with default values.
  Future<bool?> fetchDeviceFlag({required String uid}) async {
    // Check if the user document exists
    final docSnapshot = await _usersCollection.doc(uid).get();

    if (!docSnapshot.exists) {
      // Create a new user document with default values
      await _usersCollection.doc(uid).set({
        'user_id': uid,
        'hasDevice': false, // Default value
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return false; // Return the default value
    } else {
      // Fetch the existing device flag
      final data = docSnapshot.data() as Map<String, dynamic>?;
      return data?['hasDevice'] as bool?;
    }
  }

  /// Updates the device flag for the given user.
  /// If the document doesn't exist, it creates a new user document.
  Future<void> updateDeviceFlag({
    required String uid,
    required bool hasDevice,
  }) async {
    // Check if the user document exists
    final docSnapshot = await _usersCollection.doc(uid).get();

    if (!docSnapshot.exists) {
      // Create a new user document with default values
      await _usersCollection.doc(uid).set({
        'user_id': uid,
        'hasDevice': hasDevice,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update the existing document with the new device flag
      await _usersCollection.doc(uid).update({
        'hasDevice': hasDevice,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

class DeviceProvider with ChangeNotifier {
  bool? _hasDevice;
  bool? get hasDevice => _hasDevice;

  DeviceProvider(String uid) {
    // Subscribe to real-time updates for the user document.
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        bool newValue = data?['hasDevice'] as bool? ?? false;
        // Update only if there’s a change.
        if (newValue != _hasDevice) {
          _hasDevice = newValue;
          notifyListeners();
        }
      } else {
        // If the document doesn't exist, create it with default values
        FirebaseFirestore.instance.collection('users').doc(uid).set({
          'user_id': uid,
          'hasDevice': false, // Default value
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
