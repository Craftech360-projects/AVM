import 'package:flutter/material.dart';

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
    return
        // const RippleAnimation(
        //   colors: [
        //     Color.fromARGB(212, 119, 171, 255),
        //     Color.fromARGB(187, 88, 155, 255),
        //     Color.fromARGB(208, 80, 123, 253),
        //     // Color(0xFF9E00FF),
        //     // Color(0xFF5A00FF),
        //     // Color(0xFF3400D8),
        //   ],
        //   minRadius: 5,
        //   ripplesCount: 3,
        //   duration: Duration(milliseconds:3000),
        //   repeat: true,
        //   child:
        const Icon(
      Icons.bluetooth_searching,
      color: Colors.white,
      // size: 50,
    );
    // );
  }
}
