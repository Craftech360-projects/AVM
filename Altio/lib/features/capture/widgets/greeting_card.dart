import 'package:altio/backend/database/transcript_segment.dart';
import 'package:altio/backend/preferences.dart';
import 'package:altio/core/assets/app_animations.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/features/bluetooth_bloc/bluetooth_bloc.dart';
import 'package:altio/features/connectivity_bloc/connectivity_bloc.dart';
import 'package:altio/utils/websockets.dart';
import 'package:altio/widgets/transcript.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class GreetingCard extends StatefulWidget {
  final GlobalKey? tutorialKey;
  final String name;
  final String? avatarUrl;
  final bool isDisconnected;
  final BuildContext context;
  final bool hasTranscripts;
  final WebsocketConnectionStatus wsConnectionState;
  final InternetStatus? internetStatus;
  final List<TranscriptSegment>? segments;
  final bool memoryCreating;
  final ScrollController? scrollController;

  const GreetingCard({
    super.key,
    required this.name,
    required this.isDisconnected,
    required this.context,
    required this.hasTranscripts,
    required this.wsConnectionState,
    this.internetStatus,
    this.segments,
    this.memoryCreating = false,
    this.scrollController,
    this.avatarUrl,
    this.tutorialKey,
  });

  @override
  State<GreetingCard> createState() => _GreetingCardState();
}

class _GreetingCardState extends State<GreetingCard> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, connectivityState) {
        // You should use connectivityState.status for the internet status
        return GestureDetector(
          key: widget.tutorialKey,
          onTap: () {
            if (widget.segments != null && widget.segments!.isNotEmpty) {
              showModalBottomSheet(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                  ),
                ),
                backgroundColor: AppColors.purpleDark,
                useSafeArea: true,
                isScrollControlled: true,
                context: context,
                builder: (context) => SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.close_rounded,
                              size: 30,
                              color: AppColors.white,
                            ),
                          ),
                          TranscriptWidget(segments: widget.segments ?? []),
                        ]),
                  ),
                ),
              );
            }
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.7),
                  borderRadius: br5,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withAlpha(25),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(1, 2),
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
                                    'Hi! ${SharedPreferencesUtil().givenName}',
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  h4,
                                  const Text(
                                    'Change is inevitable. Always strive for the next big thing!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        h8,
                        Container(height: 1.5, color: AppColors.purpleDark),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    connectivityState.status ==
                                                ConnectivityResult.wifi ||
                                            connectivityState.status ==
                                                ConnectivityResult.mobile
                                        ? Icons.wifi_rounded
                                        : Icons.wifi_off_rounded,
                                    color: connectivityState.status ==
                                                ConnectivityResult.wifi ||
                                            connectivityState.status ==
                                                ConnectivityResult.mobile
                                        ? AppColors.white.withValues(alpha: 0.9)
                                        : AppColors.grey,
                                  ),
                                  w4,
                                  Text(
                                    'Internet',
                                    style: TextStyle(
                                      color: connectivityState.status ==
                                                  ConnectivityResult.wifi ||
                                              connectivityState.status ==
                                                  ConnectivityResult.mobile
                                          ? AppColors.white
                                              .withValues(alpha: 0.9)
                                          : AppColors.grey,
                                      fontSize: 14,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              BlocBuilder<BluetoothBloc, BluetoothState>(
                                builder: (context, state) {
                                  bool isDeviceDisconnected =
                                      state is BluetoothDisconnected;
                                  String deviceInfo = 'Disconnected';

                                  if (state is BluetoothConnected) {
                                    deviceInfo =
                                        '${state.device.name} ${(state.device.id.replaceAll(':', '').split('-').last.substring(0, 6))}';
                                    isDeviceDisconnected = false;
                                  } else {
                                    isDeviceDisconnected = true;
                                  }

                                  return Row(
                                    children: [
                                      Icon(
                                        isDeviceDisconnected
                                            ? Icons.bluetooth_disabled_rounded
                                            : Icons.bluetooth_connected_rounded,
                                        color: isDeviceDisconnected
                                            ? AppColors.grey
                                            : AppColors.white
                                                .withValues(alpha: 0.9),
                                      ),
                                      w4,
                                      Text(
                                        deviceInfo,
                                        style: TextStyle(
                                          color: isDeviceDisconnected
                                              ? AppColors.grey
                                              : AppColors.white
                                                  .withValues(alpha: 0.9),
                                          fontSize: 14,
                                          height: 1.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.segments != null && widget.segments!.isNotEmpty)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.03,
                  right: MediaQuery.of(context).size.width * 0.003,
                  child: Column(
                    children: [
                      Image.asset(
                        AppAnimations.fingerSwipe,
                        width: 130,
                        repeat: ImageRepeat.repeat,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
