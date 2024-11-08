import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/live_transcript/presentation/bloc/live_transcript/live_transcript_bloc.dart';

class BatteryIndicator extends StatelessWidget {
  const BatteryIndicator({
    super.key,
  });

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
        SizedBox(width: 4.w),
        BlocBuilder<LiveTranscriptBloc, LiveTranscriptState>(
          bloc: context.read<LiveTranscriptBloc>(),
          builder: (context, state) {
            if (state.bluetoothDeviceStatus ==
                BluetoothDeviceStatus.connected) {
              return Text(
                '${state.bleBatteryLevel}%',
                style: textTheme.bodySmall?.copyWith(fontSize: 12.h),
              );
            }
            return const SizedBox.shrink();
          },
        )
      ],
    );
  }
}
