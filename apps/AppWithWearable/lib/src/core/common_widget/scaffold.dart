import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    super.key,
    this.body,
    this.appBar,
  });
  final Widget? body;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F5FA),
      appBar: appBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE6F5FA),
              Color(0xCEF2E4FF),
            ],
            stops: [0.01, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: body,
      ),
    );
  }
}
