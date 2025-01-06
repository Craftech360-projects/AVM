import 'package:avm/backend/database/transcript_segment.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/features/bluetooth_bloc/bluetooth_bloc.dart';
import 'package:avm/core/assets/app_animations.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/features/connectivity_bloc/connectivity_bloc.dart';
import 'package:avm/utils/websockets.dart';
import 'package:avm/widgets/transcript.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tuple/tuple.dart';

class GreetingCard extends StatefulWidget {
  final String name;
  final String? avatarUrl;
  final bool isDisconnected;
  final BuildContext context;
  final bool hasTranscripts;
  final WebsocketConnectionStatus wsConnectionState;
  final InternetStatus? internetStatus;
  final List<TranscriptSegment>? segments;
  final bool memoryCreating;
  final List<Tuple2<String, String>> photos;
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
    this.photos = const [],
    this.scrollController,
    this.avatarUrl,
  });

  @override
  State<GreetingCard> createState() => _GreetingCardState();
}

class _GreetingCardState extends State<GreetingCard> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, connectivityState) {
        return GestureDetector(
          onTap: () {
            if (widget.segments != null && widget.segments!.isNotEmpty) {
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
                          child: TranscriptWidget(
                              segments: widget.segments ?? [])),
                    )
                  ],
                ),
              );
            }
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    stops: [0.3, 1.0],
                    colors: [
                      Color.fromARGB(255, 112, 186, 255),
                      Color(0xFFCDB4DB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: br12,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withAlpha(25),
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
                                    'Hi! ${SharedPreferencesUtil().givenName}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  h5,
                                  const Text(
                                    'Change is inevitable. Always strive for the next big thing!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        h10,
                        Container(height: 1.5, color: AppColors.purpleDark),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    widget.internetStatus ==
                                            InternetStatus.connected
                                        ? Icons.wifi_rounded
                                        : Icons.wifi_off_rounded,
                                    color: widget.internetStatus ==
                                            InternetStatus.connected
                                        ? AppColors.white.withValues(alpha: 0.9)
                                        : AppColors.grey,
                                  ),
                                  w5,
                                  Text(
                                    'Internet',
                                    style: TextStyle(
                                      color: connectivityState
                                              is ConnectivityConnected
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
                                      w5,
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
