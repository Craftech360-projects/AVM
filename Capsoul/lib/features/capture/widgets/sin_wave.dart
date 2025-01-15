import 'dart:math';

import 'package:capsoul/backend/schema/bt_device.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:lottie/lottie.dart';

class SineWaveWidget extends StatefulWidget {
  final double sizeMultiplier;
  final bool isWifiDisconnected;
  final bool isWebsocketError;
  final BTDeviceStruct? device;
  final InternetStatus? internetStatus;
  const SineWaveWidget(
      {super.key,
      this.sizeMultiplier = 1.0,
      required this.isWifiDisconnected,
      required this.isWebsocketError,
      this.device,
      required this.internetStatus});

  @override
  State<SineWaveWidget> createState() => _SineWaveWidgetState();
}

class _SineWaveWidgetState extends State<SineWaveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _sineAnimController;
  late Animation<double> _sineAnimation;
  late bool isWifiDisconnected = widget.isWifiDisconnected;
  late bool isWebsocketError = widget.isWebsocketError;
  late BTDeviceStruct device = widget.device!;

  @override
  void initState() {
    super.initState();

    _sineAnimController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _sineAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
        CurvedAnimation(parent: _sineAnimController, curve: Curves.linear));
    _sineAnimController.repeat();
  }

  @override
  void dispose() {
    _sineAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isWifiDisconnected = widget.internetStatus == InternetStatus.disconnected;

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _sineAnimation,
          builder: (context, child) {
            return isWifiDisconnected
                ? const SizedBox.shrink()
                : Lottie.asset(
                    'assets/lottie_animations/wave_animation.json',
                    controller: _sineAnimController,
                    onLoaded: (composition) {
                      _sineAnimController.duration = composition.duration * 0.5;
                    },
                  );
          },
        );
      },
    );
  }
}

class SinePainter extends CustomPainter {
  final Animation<double> _animation;
  final double sizeMultiplier;
  final Random _random = Random();

  SinePainter(this._animation, this.sizeMultiplier)
      : super(repaint: _animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Function to create gradient paint with glow effect
    Paint createGlowPaint(List<Color> colors, double strokeWidth) {
      return Paint()
        ..shader = LinearGradient(
          colors: colors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withValues(alpha: 0.2);
    }

    // Function to create solid paint for waves
    Paint createSolidPaint(List<Color> colors, double strokeWidth) {
      return Paint()
        ..shader = LinearGradient(
          colors: colors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;
    }

    // Draw wave with glow effect
    void drawWave(Paint glowPaint, Paint solidPaint, double frequency,
        double amplitudeBase, double amplitudeVariation) {
      Path path = Path()..moveTo(0, size.height / 2);
      double currentX = 0;
      while (currentX <= size.width) {
        double amplitude =
            amplitudeBase + _random.nextDouble() * amplitudeVariation;
        double waveLength =
            1 + _random.nextDouble() * 3; // Smaller step for smoother wave
        path.lineTo(
          currentX,
          size.height / 2 +
              sin(_animation.value + currentX * frequency * pi / size.width) *
                  amplitude, // Shift phase to move from right to left
        );
        currentX += waveLength;
      }
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, solidPaint);
    }

    // Colors for each wave
    List<List<Color>> colors = [
      [
        Colors.deepPurple,
        Colors.purple,
        Colors.purpleAccent,
        Colors.deepPurpleAccent,
        Colors.blueAccent,
        Colors.indigoAccent,
        Colors.pinkAccent
      ],
      [
        Colors.deepPurple.withValues(alpha: 0.5),
        Colors.purple.withValues(alpha: 0.5),
        Colors.purpleAccent.withValues(alpha: 0.5),
        Colors.deepPurpleAccent.withValues(alpha: 0.5),
        Colors.blueAccent.withValues(alpha: 0.5),
        Colors.indigoAccent.withValues(alpha: 0.5),
        Colors.pinkAccent.withValues(alpha: 0.5)
      ],
      [AppColors.blue, Colors.lightBlueAccent, Colors.cyan, Colors.tealAccent],
      [
        const Color.fromARGB(219, 239, 179, 88),
        const Color.fromARGB(255, 243, 223, 201),
        Colors.amber,
        AppColors.yellow
      ]
    ];

    // Draw each wave with glow and solid paint
    drawWave(createGlowPaint(colors[0], 10), createSolidPaint(colors[0], 3), 4,
        10, 5);
    drawWave(createGlowPaint(colors[1], 10), createSolidPaint(colors[1], 4), 6,
        7.5, 3.75);
    drawWave(createGlowPaint(colors[2], 10), createSolidPaint(colors[2], 2), 5,
        5, 2.5);
    drawWave(createGlowPaint(colors[3], 10), createSolidPaint(colors[3], 1), 6,
        3.5, 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
