import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:friend_private/src/core/constant/constant.dart';

class BatteryIndicator extends StatelessWidget {
  const BatteryIndicator({
    super.key,
    this.batteryLevel,
  });
  final int? batteryLevel;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SvgPicture.asset(
            height: 16.h,
            IconImage.batteryIndicator,
          ),
        ),
        // BlocBuilder<LiveTranscriptBloc, LiveTranscriptState>(
        //   bloc: context.read<LiveTranscriptBloc>(),
        //   builder: (context, state) {
        //     if (state.bluetoothDeviceStatus ==
        //         BluetoothDeviceStatus.connected) {
        //       return
        Text(
        
          '$batteryLevel %',
          style: textTheme.bodySmall?.copyWith(fontSize: 12.h),
        ),
        //     }
        //     return const SizedBox.shrink();
        //   },
        // )
      ],
    );
  }
}
