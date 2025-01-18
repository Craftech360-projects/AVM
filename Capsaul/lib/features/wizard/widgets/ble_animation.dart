import 'dart:async';

import 'package:capsaul/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BleAnimation extends StatefulWidget {
  const BleAnimation({
    required this.child,
    this.colors = const [
      Color.fromARGB(71, 155, 108, 186),
      Color.fromARGB(97, 200, 134, 253),
      Color.fromARGB(70, 225, 165, 255),
    ],
    this.delay = Duration.zero,
    this.repeat = false,
    this.minRadius = 30,
    this.ripplesCount = 3,
    this.duration = const Duration(milliseconds: 2300),
    super.key,
  });

  final Widget child;
  final Duration delay;
  final double minRadius;
  final List<Color> colors;
  final int ripplesCount;
  final Duration duration;
  final bool repeat;

  @override
  BleAnimationState createState() => BleAnimationState();
}

class BleAnimationState extends State<BleAnimation>
    with TickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    Timer? animationTimer;

    animationTimer = Timer(widget.delay, () {
      if (_controller != null && mounted) {
        widget.repeat
            ? _controller!.repeat(reverse: false)
            : _controller!.forward();
      }
      animationTimer?.cancel();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: CirclePainter(
          _controller,
          colors: widget.colors,
          minRadius: widget.minRadius,
          wavesCount: widget.ripplesCount,
        ),
        child: CircleAvatar(
          minRadius: (widget.minRadius - 10.h),
          backgroundColor: AppColors.purpleBright,
          child: widget.child,
        ),
        // child: widget.child,
      );
}

class CirclePainter extends CustomPainter {
  CirclePainter(
    this.animation, {
    required this.wavesCount,
    required this.colors,
    this.minRadius,
  }) : super(repaint: animation);

  final List<Color> colors;
  final double? minRadius;
  final int wavesCount;
  final Animation<double>? animation;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(0, 0, size.width, size.height);

    // Draw 3 waves
    for (int wave = 0; wave < 3; wave++) {
      circle(
        canvas,
        rect,
        minRadius,
        wave,
        animation!.value,
        wavesCount,
        colors,
      );
    }
  }

  void circle(
    Canvas canvas,
    Rect rect,
    double? minRadius,
    int wave,
    double value,
    int? length,
    List<Color> colors,
  ) {
    Color color = colors[wave % colors.length];
    double r;

    // Smooth opacity transition
    final double opacity = (1 - ((wave) / length!) - value).clamp(0.0, 1.0);
    color = color.withValues(alpha: opacity);

    r = minRadius! *
        (1 + wave + value); // Adjust radius for spacing between ripples

    // Create paint for the main circle
    final Paint paint = Paint()..color = color;
    canvas.drawCircle(rect.center, r, paint);

    // Create paint for the glow effect
    final Paint glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.3)
        ], // Smooth glow effect
        stops: const [0.7, 1.0],
      ).createShader(Rect.fromCircle(center: rect.center, radius: r * 1.5))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6; // Adjust glow width for smoothness
    canvas.drawCircle(rect.center, r, glowPaint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) => true;
}
