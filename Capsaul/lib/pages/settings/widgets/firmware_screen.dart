import 'dart:developer';
import 'dart:io';

import 'package:capsaul/backend/preferences.dart';
import 'package:capsaul/core/constants/constants.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:capsaul/pages/home/custom_scaffold.dart';
import 'package:capsaul/pages/settings/functions/firware_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:path_provider/path_provider.dart';

class FirmwareScreen extends StatefulWidget {
  const FirmwareScreen({super.key});

  @override
  State<FirmwareScreen> createState() => _FirmwareScreenState();
}

class _FirmwareScreenState extends State<FirmwareScreen> {
  final DownloadController _downloadController = DownloadController();
  String buttonText = "Check for Updates";
  String currentVersion = "1.0.3";
  String? latestVersion;
  String? firmwareUrl;
  bool isDownloading = false;
  var deviceId = SharedPreferencesUtil().deviceId;

  void handleCheckForUpdates() async {
    final firmwareData = await checkFirmwareUpdate();
    if (firmwareData != null) {
      setState(() {
        latestVersion = firmwareData["latestVersion"];
        firmwareUrl = firmwareData["firmwareUrl"];

        if (latestVersion != currentVersion) {
          buttonText = "Download Update";
        } else {
          buttonText = "Firmware is Up-to-date";
        }
      });
    } else {
      avmSnackBar(context, "Failed to fetch firmware details.");
    }
  }

  void handleDownloadUpdate() async {
    if (firmwareUrl != null) {
      setState(() {
        isDownloading = true;
      });
      try {
        await _downloadController.downloadFirmware(firmwareUrl!);
        setState(() {
          buttonText = "Install Firmware";
        });
      } catch (e) {
        setState(() {
          buttonText = "Download Update";
        });
      } finally {
        setState(() {
          isDownloading = false;
        });
      }
    }
  }

  void installFirmware({
    required BluetoothDevice device,
    required String firmwarePath,
    required BluetoothService service,
    required BluetoothCharacteristic characteristic,
  }) async {
    try {
      setState(() {
        isDownloading = true;
      });

      final firmwareFile = File(firmwarePath);
      final firmwareBytes = await firmwareFile.readAsBytes();

      await sendFirmwareInChunks(
        characteristic: characteristic,
        firmwareBytes: firmwareBytes,
        onProgress: (progress) {
          _downloadController.progressNotifier.value = progress;
        },
      );

      await triggerFirmwareUpdate(characteristic: characteristic);

      setState(() {
        buttonText = "Installation Complete";
        isDownloading = false;
      });
    } catch (e) {
      setState(() {
        buttonText = "Install Firmware";
        isDownloading = false;
      });
    }
  }

  Future<BluetoothService> getService(
      BluetoothDevice device, String serviceUuid) async {
    try {
      final services = await device.discoverServices();
      for (var service in services) {
        log(service.uuid.toString()); // Log service UUID
        for (var char in service.characteristics) {
          log("Characteristic UUID: ${char.uuid}"); // Log characteristic UUIDs
        }
      }

      // Check if the service UUID you're looking for is in the available services
      final service = services.firstWhere(
        (s) => s.uuid.toString() == serviceUuid,
        orElse: () => throw Exception("Service not found"),
      );

      log("Service found: $serviceUuid");
      return service;
    } catch (e) {
      log("Error during service discovery: $e");
      rethrow;
    }
  }

  Future<BluetoothDevice> getConnectedDevice(String deviceId) async {
    BluetoothAdapterState adapterState =
        await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      if (!mounted) return Future.error("Bluetooth is off");
      avmSnackBar(context, "Please enable Bluetooth to continue.");
      return Future.error("Bluetooth is off");
    }

    final devices = FlutterBluePlus.connectedDevices;

    final device = devices.firstWhere(
      (d) => d.remoteId.toString() == deviceId,
      orElse: () => throw Exception("Device not connected"),
    );

    return device;
  }

  Future<BluetoothCharacteristic> getCharacteristic(
      BluetoothService service, String characteristicUuid) async {
    try {
      final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString() == characteristicUuid,
        orElse: () => throw Exception("Characteristic not found"),
      );

      log("Characteristic found: $characteristicUuid");
      return characteristic;
    } catch (e) {
      log("Error during characteristic discovery: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showBackBtn: true,
      showGearIcon: true,
      title: Text(
        "Firmware Settings",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.greyOffWhite,
                borderRadius: br8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  h8,
                  const Text(
                    "Keep your device running smoothly by updating to the latest firmware. This ensures you have the newest features and bug fixes.",
                    style: TextStyle(fontSize: 14),
                  ),
                  Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Current Version:",
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        currentVersion,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  h8,
                  if (latestVersion != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Latest Version:",
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          latestVersion!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            h16,
            if (isDownloading)
              Column(
                children: [
                  h16,
                  ValueListenableBuilder<double>(
                    valueListenable: _downloadController.progressNotifier,
                    builder: (context, progress, child) {
                      return Column(
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor:
                                AppColors.purpleDark.withValues(alpha: 0.5),
                            color: AppColors.purpleDark,
                          ),
                          h8,
                          Text(
                            "Downloading... ${(progress * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (buttonText == "Check for Updates") {
                    handleCheckForUpdates();
                  } else if (buttonText == "Download Update") {
                    handleDownloadUpdate();

                    try {
                      // Get the BluetoothDevice object using deviceId
                      final device = await getConnectedDevice(deviceId);

                      // Replace the hardcoded UUIDs with the actual service and characteristic UUIDs
                      final service = await getService(device, "serviceUuid");
                      final characteristic = await getCharacteristic(
                          service, "characteristicUuid");

                      final directory =
                          await getApplicationDocumentsDirectory();
                      final firmwarePath = "${directory.path}/firmware.bin";

                      // Call installFirmware with the correct BluetoothDevice object
                      installFirmware(
                        device: device,
                        firmwarePath: firmwarePath,
                        service: service,
                        characteristic: characteristic,
                      );
                    } catch (e) {
                      avmSnackBar(context,
                          "Failed to install firmware! Please try again");
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
