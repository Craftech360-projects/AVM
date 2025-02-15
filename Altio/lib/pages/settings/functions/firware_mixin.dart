import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<Map<String, String>?> checkFirmwareUpdate() async {
  const baseUrl =
      "https://living-alien-polite.ngrok-free.app/v2/firmware/latest";
  const deviceModel = "1234";
  const firmwareRevision = "1.0.3";
  const hardwareRevision = "A1";
  const manufacturerName = "ExampleCorp";

  final url = Uri.parse(
      "$baseUrl?device_model=$deviceModel&firmware_revision=$firmwareRevision&hardware_revision=$hardwareRevision&manufacturer_name=$manufacturerName");

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        "latestVersion": data['version'],
        "firmwareUrl": data['file_url'],
        "releaseNotes": data['release_notes'],
      };
    } else {}
  } on Exception catch (e) {
    log("Error: $e");
  }
  return null;
}

class DownloadController {
  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);

  Future<void> downloadFirmware(String url) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savePath = "${directory.path}/firmware.bin";

      final dio = Dio();
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            progressNotifier.value = received / total;
          }
        },
      );

      progressNotifier.value = 1.0; // Mark as complete
    } on Exception catch (e) {
      log("Error during firmware download: $e");
      progressNotifier.value = 0.0; // Reset progress on failure
    }
  }
}

Future<void> triggerFirmwareUpdate({
  required BluetoothCharacteristic characteristic,
}) async {
  const List<int> triggerCommand = [0x01];
  await characteristic.write(triggerCommand, withoutResponse: true);
}

Future<void> sendFirmwareInChunks({
  required BluetoothCharacteristic characteristic,
  required List<int> firmwareBytes,
  required Function(double progress) onProgress,
}) async {
  const int chunkSize = 20; // BLE MTU size limit, often 20 bytes
  int totalBytes = firmwareBytes.length;
  int bytesSent = 0;

  while (bytesSent < totalBytes) {
    int end = (bytesSent + chunkSize > totalBytes)
        ? totalBytes
        : bytesSent + chunkSize;
    final chunk = firmwareBytes.sublist(bytesSent, end);

    await characteristic.write(chunk,
        withoutResponse: true); // Use `withoutResponse` for faster writes
    bytesSent = end;

    // Update progress
    double progress = bytesSent / totalBytes;
    onProgress(progress);
  }

  log("Firmware transfer complete.");
}
