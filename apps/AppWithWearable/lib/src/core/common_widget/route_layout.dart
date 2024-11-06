import 'package:flutter/material.dart';

class RouteLayout extends StatelessWidget {
  const RouteLayout({
    super.key,
    required this.selectedIndex,
    required this.child,
  });
  final int selectedIndex;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
