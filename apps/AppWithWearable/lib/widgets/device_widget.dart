import 'package:flutter/material.dart';
import 'package:friend_private/src/core/constant/constant.dart';

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
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    // _animation = Tween<double>(begin: 1, end: 0.8).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Image.asset(
          //   "assets/images/stars.png",
          // ),

          // Image.asset("assets/images/blob.png"),
          Image.asset(
            IconImage.avmLogo,
            height: (MediaQuery.sizeOf(context).height <= 700 ? 130 : 160),
            width: (MediaQuery.sizeOf(context).height <= 700 ? 130 : 160),
          )
        ],
      ),
    );
  }
}
