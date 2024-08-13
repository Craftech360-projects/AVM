import 'package:flutter/material.dart';
import 'package:friend_private/pages/capture/widgets/ripple_animation.dart';

class ScanningUI extends StatefulWidget {
  const ScanningUI({super.key, required this.string1, required this.string2});

  final String string1;
  final String string2;

  @override
  State<ScanningUI> createState() => _ScanningUIState();
}

class _ScanningUIState extends State<ScanningUI> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const RippleAnimation(
            colors: [Color(0xFF9E00FF), Color(0xFF5A00FF), Color(0xFF3400D8)],
            minRadius: 60,
            ripplesCount: 6,
            duration: Duration(milliseconds: 3000),
            repeat: true,
            child: Icon(
              Icons.bluetooth_searching,
              color: Colors.white,
              size: 100,
            ),
          ),
          const SizedBox(height: 58),
          // Center(
          //   child: SizedBox(
          //     height: 280, // Fixed height container
          //     child: Center(
          //       child: SineWaveWidget(sizeMultiplier: 0.7),
          //     ),
          //   ),
          // ),
          Text(
            widget.string1,
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              color: Colors.white,
              fontSize: 32.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w700,
              // useGoogleFonts: GoogleFonts.asMap().containsKey('SF Pro Display'),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            widget.string2,
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
