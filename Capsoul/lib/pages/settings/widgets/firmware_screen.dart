import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:capsoul/pages/home/custom_scaffold.dart';
import 'package:flutter/material.dart';

class FirmwareScreen extends StatefulWidget {
  const FirmwareScreen({super.key});

  @override
  State<FirmwareScreen> createState() => _FirmwareScreenState();
}

class _FirmwareScreenState extends State<FirmwareScreen> {
  @override
  Widget build(BuildContext context) {
    final String currentVersion = "1.0.3";
    final String latestVersion = "1.2.0";
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
                  border: Border.all(color: AppColors.black),
                  borderRadius: br12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Updates",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  h8,
                  const Text(
                    "Keep your device running smoothly by updating to the latest firmware. This ensures you have the newest features and bug fixes.",
                    style: TextStyle(fontSize: 15, color: AppColors.grey),
                  ),
                  h24,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Current Version:",
                        style: TextStyle(fontSize: 17),
                      ),
                      Text(
                        currentVersion,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Latest Version:",
                        style: TextStyle(fontSize: 17),
                      ),
                      Text(
                        latestVersion,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  avmSnackBar(context, "Firmware update initiated");
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Update to Latest Version",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
