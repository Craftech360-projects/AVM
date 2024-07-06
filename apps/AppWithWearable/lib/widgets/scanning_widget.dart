import 'package:flutter/material.dart';

class ScanningAnimationWidget extends StatefulWidget {
  final double sizeMultiplier;

  const ScanningAnimationWidget({super.key, this.sizeMultiplier = 1.0});

  @override
  State<ScanningAnimationWidget> createState() =>
      _ScanningAnimationWidgetState();
}

class _ScanningAnimationWidgetState extends State<ScanningAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1, end: 0.8).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360 * widget.sizeMultiplier,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Image.asset(
                  "assets/images/wave.gif",
                  height: 450 * widget.sizeMultiplier * _animation.value,
                  width: 450 * widget.sizeMultiplier * _animation.value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
