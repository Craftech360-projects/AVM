import 'package:flutter/material.dart';
import 'package:friend_private/pages/capture/widgets/ripple_animation.dart';

class ScanningUI extends StatefulWidget {
  const ScanningUI({
    super.key,
    // required this.string1,
    // required this.string2,
  });

  // final String string1;
  // final String string2;

  @override
  State<ScanningUI> createState() => _ScanningUIState();
}

class _ScanningUIState extends State<ScanningUI> {
  @override
  Widget build(BuildContext context) {
    return const RippleAnimation(
      colors: [
        Color.fromARGB(255, 231, 223, 236),
        Color.fromARGB(255, 131, 130, 132),
        Color.fromARGB(255, 225, 224, 203),
        // Color(0xFF9E00FF),
        // Color(0xFF5A00FF),
        // Color(0xFF3400D8),
      ],
      minRadius: 10,
      ripplesCount: 2,
      duration: Duration(milliseconds: 3000),
      repeat: true,
      child: Icon(
        Icons.bluetooth_searching,
        color: Colors.white,
        // size: 50,
      ),
    );
  }
}
