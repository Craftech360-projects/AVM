// lib/services/flutter_blue_wrapper.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Mockable wrapper for FlutterBluePlus static methods
class FlutterBluePlusMockable {
  Future<void> connectToDevice(
    String deviceId, {
    bool autoConnect = true,
    Duration? timeout,
    bool queue = true,
  }) async {
    final device = BluetoothDevice.fromId(deviceId);
    try {
      if (!autoConnect) {
        return await device.connect(autoConnect: true);
      }

      await device.connect(autoConnect: true);
      await device.connectionState
          .where((state) => state == BluetoothConnectionState.connected)
          .first;

      if (Platform.isAndroid) await device.requestMtu(512);
    } catch (e) {
      debugPrint('connectToDevice failed: $e');
    }
  }

  Future<void> disconnectDevice(String deviceId) async {
    final device = BluetoothDevice.fromId(deviceId);
    try {
      await device.disconnect();
    } catch (e) {
      debugPrint('disconnectDevice failed: $e');
    }
  }

  /// Start scanning for devices
  Future<void> startScan({
    List<Guid> withServices = const [],
    Duration? timeout,
    Duration? removeIfGone,
    bool oneByOne = false,
    bool androidUsesFineLocation = false,
  }) {
    return FlutterBluePlus.startScan(
      withServices: withServices,
      timeout: timeout,
      removeIfGone: removeIfGone,
      oneByOne: oneByOne,
      androidUsesFineLocation: androidUsesFineLocation,
    );
  }

  /// Stop scanning for devices
  Future<void> stopScan() {
    return FlutterBluePlus.stopScan();
  }

  /// Get current adapter state
  Stream<BluetoothAdapterState> get adapterState {
    return FlutterBluePlus.adapterState;
  }

  /// Get scan results as a stream
  Stream<List<ScanResult>> get scanResults {
    return FlutterBluePlus.scanResults;
  }

  /// Check if currently scanning
  Stream<bool> get isScanning {
    return FlutterBluePlus.isScanning;
  }

  /// Check if currently scanning
  bool get isScanningNow {
    return FlutterBluePlus.isScanningNow;
  }
}
