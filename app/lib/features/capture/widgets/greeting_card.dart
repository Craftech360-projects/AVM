import 'package:flutter/material.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/core/constants/constants.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/features/capture/widgets/widgets.dart';
import 'package:friend_private/utils/websockets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tuple/tuple.dart';

class GreetingCard extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool isDisconnected;
  final BuildContext context;
  final bool hasTranscripts;
  // Changed from ConnectionState to WebsocketConnectionStatus
  final WebsocketConnectionStatus wsConnectionState;
  final BTDeviceStruct? device; // Changed to match CaptureCard
  final InternetStatus? internetStatus; // Made nullable to match CaptureCard
  final List<TranscriptSegment>? segments; // Changed to match CaptureCard type
  final bool memoryCreating;
  final List<Tuple2<String, String>>
      photos; // Changed to match CaptureCard type
  final ScrollController?
      scrollController; // Made nullable to match CaptureCard

  const GreetingCard({
    super.key,
    required this.name,
    required this.isDisconnected,
    required this.context,
    required this.hasTranscripts,
    required this.wsConnectionState,
    this.device,
    this.internetStatus,
    this.segments,
    this.memoryCreating = false,
    this.photos = const [],
    this.scrollController,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    bool isDeviceDisconnected = device == null;
    return GestureDetector(
      onTap: () {
        if (segments != null && segments!.isNotEmpty) {
          showModalBottomSheet(
            useSafeArea: true,
            isScrollControlled: true,
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: getTranscriptWidget(
                      memoryCreating,
                      segments ?? [],
                      photos,
                      device,
                    ),
                  ),
                )
              ],
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFA2D2FF),
                Color(0xFFCDB4DB),
              ],
              // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: br12,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                spreadRadius: 4,
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi Alex!${SharedPreferencesUtil().givenName}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white),
                            ),
                            h5,
                            const Text(
                              'Change is inevitable. Always strive for the next big thing!',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  h10,
                  Container(height: 1, color: AppColors.purpleDark),
                  if (segments != null && segments!.isNotEmpty) ...[
                    h15,
                    AnimatedOpacity(
                      opacity: segments!.isNotEmpty ? 1.0 : 0.0,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      child: const Text(
                        'Swipe to create memory',
                        style: TextStyle(
                          color: Color.fromARGB(129, 31, 31, 31),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Status: INTERNET Connection
                        Row(
                          children: [
                            if (internetStatus != null)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: InternetStatus.connected ==
                                          InternetStatus.connected
                                      ? AppColors.green
                                      : AppColors.red,
                                ),
                              ),
                            w5,
                            const Text(
                              'Internet',
                              style: TextStyle(
                                color: InternetStatus.connected ==
                                        InternetStatus.connected
                                    ? Colors.black
                                    : Colors.grey,
                                fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDeviceDisconnected
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                            w5,
                            Text(
                              isDeviceDisconnected
                                  ? 'Disconnected'
                                  : '${device?.name ?? ''} ${device?.id.replaceAll(':', '').split('-').last.substring(0, 6) ?? ''}',
                              style: TextStyle(
                                color: isDeviceDisconnected
                                    ? AppColors.grey
                                    : AppColors.black,
                                fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
