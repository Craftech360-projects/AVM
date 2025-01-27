// import 'dart:async';
// import 'package:flutter/material.dart';

// class RippleAnimation extends StatefulWidget {
//   const RippleAnimation({
//     required this.child,
//     this.colors = const [
//       Color(0xFF0D0C1D),
//       Color(0xFF291A5C),
//       Color(0xFF582F98)
//     ],
//     this.delay = Duration.zero,
//     this.repeat = false,
//     this.minRadius = 60,
//     this.ripplesCount = 5,
//     this.duration = const Duration(milliseconds: 2300),
//     super.key,
//   });

//   final Widget child;
//   final Duration delay;
//   final double minRadius;
//   final List<Color> colors;
//   final int ripplesCount;
//   final Duration duration;
//   final bool repeat;

//   @override
//   RippleAnimationState createState() => RippleAnimationState();
// }

// class RippleAnimationState extends State<RippleAnimation>
//     with TickerProviderStateMixin {
//   AnimationController? _controller;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       duration: widget.duration,
//       vsync: this,
//     );

//     Timer? animationTimer;

//     animationTimer = Timer(widget.delay, () {
//       if (_controller != null && mounted) {
//         widget.repeat ? _controller!.repeat() : _controller!.forward();
//       }
//       animationTimer?.cancel();
//     });
//   }

//   @override
//   Widget build(BuildContext context) => CustomPaint(
//         painter: CirclePainter(
//           _controller,
//           colors: widget.colors,
//           minRadius: widget.minRadius,
//           wavesCount: widget.ripplesCount + 2,
//         ),
//         child: widget.child,
//       );
// }

// class CirclePainter extends CustomPainter {
//   CirclePainter(
//     this.animation, {
//     required this.wavesCount,
//     required this.colors,
//     this.minRadius,
//   }) : super(repaint: animation);

//   final List<Color> colors;
//   final double? minRadius;
//   final int wavesCount;
//   final Animation<double>? animation;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Rect rect = Rect.fromLTRB(0, 0, size.width, size.height);
//     for (int wave = 0; wave <= wavesCount; wave++) {
//       circle(
//         canvas,
//         rect,
//         minRadius,
//         wave,
//         animation!.value,
//         wavesCount,
//         colors,
//       );
//     }
//   }

//   void circle(
//     Canvas canvas,
//     Rect rect,
//     double? minRadius,
//     int wave,
//     double value,
//     int? length,
//     List<Color> colors,
//   ) {
//     Color color = colors[wave % colors.length];
//     double r;
//     if (wave != 0) {
//       final double opacity =
//           (1 - ((wave - 1) / length!) - value).clamp(0.0, 1.0);
//       color = color.withValues(opacity);

//       r = minRadius! * (1 + (wave * value)) * value;
//       final Paint paint = Paint()..color = color;
//       canvas.drawCircle(rect.center, r, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(CirclePainter oldDelegate) => true;
// }

import 'dart:async';
import 'package:flutter/material.dart';

class RippleAnimation extends StatefulWidget {
  const RippleAnimation({
    required this.child,
    this.colors = const [
      Color(0xFF0D0C1D),
      Color(0xFF291A5C),
      Color(0xFF582F98),
      Color(0xFF7B3FA2),
      Color(0xFFB465F5),
      Color(0xFFD38DF5),
    ],
    this.delay = Duration.zero,
    this.repeat = false,
    this.minRadius = 30,
    this.ripplesCount = 5,
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
  RippleAnimationState createState() => RippleAnimationState();
}

class RippleAnimationState extends State<RippleAnimation>
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
        widget.repeat ? _controller!.repeat() : _controller!.forward();
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
        child: widget.child,
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
    for (int wave = 0; wave <= wavesCount; wave++) {
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
    if (wave != 0) {
      final double opacity =
          (1 - ((wave - 1) / length!) - value).clamp(0.0, 1.0);
      color = color.withValues(alpha: opacity);

      r = minRadius! * (1 + (wave * value)) * value;

      // Create paint for the main circle
      final Paint paint = Paint()..color = color;
      canvas.drawCircle(rect.center, r, paint);

      // Create paint for the glow effect
      final Paint glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.0), color.withValues(alpha: 0.5)],
          stops: [0.7, 1.0],
        ).createShader(Rect.fromCircle(center: rect.center, radius: r * 1.5))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10;
      canvas.drawCircle(rect.center, r, glowPaint);
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) => true;
}
