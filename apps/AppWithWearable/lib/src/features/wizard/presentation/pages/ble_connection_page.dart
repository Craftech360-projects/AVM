import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/live_transcript/presentation/bloc/live_transcript_bloc.dart';
import 'package:friend_private/src/features/wizard/presentation/pages/finalize_page.dart';
import 'package:friend_private/src/features/wizard/presentation/widgets/ble_animation.dart';
import 'package:go_router/go_router.dart';

class BleConnectionPage extends StatefulWidget {
  const BleConnectionPage({super.key});
  static const String name = 'BleConnectionPage';
  @override
  State<BleConnectionPage> createState() => _BleConnectionPageState();
}

class _BleConnectionPageState extends State<BleConnectionPage> {
  late LiveTranscriptBloc _liveTranscriptBloc;

  @override
  void initState() {
    super.initState();
    _liveTranscriptBloc = BlocProvider.of<LiveTranscriptBloc>(context);
    _liveTranscriptBloc.add(ScannedDevices());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CustomScaffold(
      appBar: AppBar(
         backgroundColor: const Color(0xFFE6F5FA),
        title: Text(
          'Connect your AVM',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 20.h,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: 50.h,
          left: 14.w,
          right: 14.w,
          bottom: 10.h,
        ),
        child: Center(
          child: BlocBuilder<LiveTranscriptBloc, LiveTranscriptState>(
            bloc: _liveTranscriptBloc,
            builder: (context, state) {
              final isConnected =
                  state.bleConnectionStatus == BleConnectionStatus.connected;
              final isLoading =
                  state.bleConnectionStatus == BleConnectionStatus.loading;
              final hasDevicesNearby = state.visibleDevices.isNotEmpty;

              return Column(
                children: [
                  /// Logo
                  Image.asset(
                    IconImage.avmLogo,
                    height: 30.h,
                  ),
                  SizedBox(height: 150.h),

                  /// Bluetooth Animation
                  BleAnimation(
                    minRadius: 40.h,
                    ripplesCount: 6,
                    duration: const Duration(milliseconds: 3000),
                    repeat: true,
                    child: Icon(
                      Icons.bluetooth_searching,
                      color: Colors.white,
                      size: 30.h,
                    ),
                  ),
                  SizedBox(height: 140.h),

                  /// Connection Status Text
                  if (isConnected)
                    Text(
                      '${state.connectedDevice?.name} (${state.connectedDevice?.id})\nConnected',
                      style: textTheme.titleSmall,
                    )
                  else
                    Text(
                      isLoading
                          ? 'Searching'
                          : hasDevicesNearby
                              ? '${state.visibleDevices.length} DEVICE FOUND NEARBY'
                              : 'No devices found',
                      style: textTheme.titleSmall,
                    ),

                  const Spacer(),

                  /// List of Devices
                  if (!isConnected)
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: state.visibleDevices.length,
                      itemBuilder: (context, index) {
                        final device = state.visibleDevices[index];
                        return CustomElevatedButton(
                          backgroundColor: CustomColors.white,
                          onPressed: () {
                            _liveTranscriptBloc
                                .add(SelectedDevice(deviceId: device.id));
                          },
                          child: ListTile(
                            visualDensity: const VisualDensity(vertical: -3),
                            title: Text(
                              '${device.name} (${device.id})',
                              style: textTheme.bodyLarge?.copyWith(
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            trailing: isLoading
                                ? SizedBox(
                                    height: 14.h,
                                    width: 14.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5.h,
                                      color: CustomColors.blackPrimary,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        );
                      },
                    ),
                  SizedBox(height: 10.h),

                  /// Pairing/Unpairing Button
                  SizedBox(
                    width: double.maxFinite,
                    height: 50.h,
                    child: CustomElevatedButton(
                      backgroundColor: isConnected
                          ? CustomColors.blackPrimary
                          : CustomColors.greyLight,
                      onPressed: () {
                        if (isConnected) {
                          _liveTranscriptBloc.add(
                            DisconnectDevice(
                                btDeviceStruct: state.connectedDevice!),
                          );
                        }
                        context.goNamed(FinalizePage.name);
                      },
                      child: Text(
                        isConnected ? 'UnPair Device' : 'Pair Device',
                        style: textTheme.labelLarge?.copyWith(
                          color: CustomColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
