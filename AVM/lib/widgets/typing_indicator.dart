import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  TypingIndicatorState createState() => TypingIndicatorState();
}

class TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Increased duration for slower animation
    )..repeat();

    _animation1 = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6)),
    );

    _animation2 = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8)), // Delayed fade-in
    );

    _animation3 = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)), // Further delayed fade-in
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: _animation1,
          child: const Dot(),
        ),
        w5,
        FadeTransition(
          opacity: _animation2,
          child: const Dot(),
        ),
        w5,
        FadeTransition(
          opacity: _animation3,
          child: const Dot(),
        ),
      ],
    );
  }
}

class Dot extends StatelessWidget {
  const Dot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7.5,
      height: 7.5,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.grey,
      ),
    );
  }
}
