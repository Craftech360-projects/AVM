import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceFlagService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  /// Sets (or inserts) the device flag for the given user.
  /// If the document already exists, merge with existing data.
  Future<void> setDeviceFlag({
    required String uid,
    required bool hasDevice,
  }) async {
    await _usersCollection.doc(uid).set({
      'hasDevice': hasDevice,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Fetches the device flag for the given user.
  /// Returns `true`/`false` if the flag exists, or `null` if not found.
  Future<bool?> fetchDeviceFlag({required String uid}) async {
    DocumentSnapshot doc = await _usersCollection.doc(uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['hasDevice'] as bool?;
    }
    return null;
  }

  /// Updates the device flag for the given user.
  Future<void> updateDeviceFlag({
    required String uid,
    required bool hasDevice,
  }) async {
    await _usersCollection.doc(uid).update({
      'hasDevice': hasDevice,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
