import 'package:altio/core/assets/app_images.dart';
import 'package:flutter/material.dart';

class DeviceAnimationWidget extends StatefulWidget {
  final bool animatedBackground;
  // final double sizeMultiplier;

  const DeviceAnimationWidget({
    super.key,
    // this.sizeMultiplier = 1.0,
    this.animatedBackground = true,
  });

  @override
  State<DeviceAnimationWidget> createState() => _DeviceAnimationWidgetState();
}

class _DeviceAnimationWidgetState extends State<DeviceAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  // late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    // _animation = Tween<double>(begin: 1, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        AppImages.appLogo,
        height: (MediaQuery.sizeOf(context).height <= 700 ? 130 : 120),
        width: (MediaQuery.sizeOf(context).height <= 700 ? 130 : 120),
      ),
    );
  }
}
