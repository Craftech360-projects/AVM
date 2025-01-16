import 'package:capsoul/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ScreenSkeleton extends StatelessWidget {
  const ScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          const Skeleton(height: 180, width: double.infinity),
          h30,
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) => const Column(
                children: [
                  Skeleton(height: 100, width: double.infinity),
                  h20,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.height, this.width});

  final double? height, width;

  @override
  SkeletonState createState() => SkeletonState();
}

class SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: br15,
        ),
      ),
    );
  }
}
