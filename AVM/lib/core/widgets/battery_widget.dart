import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BatteryWidget extends StatelessWidget {
  final int batteryLevel;

  const BatteryWidget({
    super.key,
    required this.batteryLevel,
  });

  @override
  Widget build(BuildContext context) {
    final clampedBatteryLevel = batteryLevel.clamp(0, 100);

    Color batteryColor;
    if (clampedBatteryLevel > 50) {
      batteryColor = AppColors.green;
    } else if (clampedBatteryLevel > 20) {
      batteryColor = AppColors.orange;
    } else {
      batteryColor = AppColors.red;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: br1,
          ),
        ),
        h1,
        Container(
          width: 12,
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.black, width: 1.5),
            borderRadius: br2,
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: clampedBatteryLevel / 100,
                  widthFactor: 1.0,
                  child: Container(
                    color: batteryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
