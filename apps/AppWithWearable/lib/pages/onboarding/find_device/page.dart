import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:AVMe/backend/schema/bt_device.dart';
import 'package:AVMe/utils/ble/scan.dart';
import 'package:url_launcher/url_launcher.dart';
import 'found_devices.dart';

class FindDevicesPage extends StatefulWidget {
  const FindDevicesPage({Key? key}) : super(key: key);

  @override
  _FindDevicesPageState createState() => _FindDevicesPageState();
}

class _FindDevicesPageState extends State<FindDevicesPage>
    with SingleTickerProviderStateMixin {
  List<BTDeviceStruct?> deviceList = [];
  late Timer _didNotMakeItTimer;
  late Timer _findDevicesTimer;
  bool enableInstructions = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _scanDevices();
    });
  }

  @override
  void dispose() {
    _findDevicesTimer.cancel();
    _didNotMakeItTimer.cancel();
    super.dispose();
  }

  Future<void> _scanDevices() async {
    _didNotMakeItTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        enableInstructions = true;
      });
    });

    Map<String, BTDeviceStruct?> foundDevicesMap = {};

    _findDevicesTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) async {
      List<BTDeviceStruct?> foundDevices = await scanDevices();

      Map<String, BTDeviceStruct?> updatedDevicesMap = {};
      for (final device in foundDevices) {
        if (device != null) {
          updatedDevicesMap[device.id] = device;
        }
      }

      foundDevicesMap
          .removeWhere((id, _) => !updatedDevicesMap.containsKey(id));
      foundDevicesMap.addAll(updatedDevicesMap);

      List<BTDeviceStruct?> orderedDevices = foundDevicesMap.values.toList();

      if (orderedDevices.isNotEmpty) {
        setState(() {
          deviceList = orderedDevices;
        });
        _didNotMakeItTimer.cancel();
      }
    });
  }

  void _launchURL() async {
    const url =
        'https://discord.com/servers/based-hardware-1192313062041067520';
    if (!await canLaunch(url)) {
      throw 'Could not launch $url';
    }
    await launch(url);
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: size.height,
          width: size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splash.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FoundDevices(deviceList: deviceList),
                if (deviceList.isEmpty && enableInstructions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 55, 55, 55),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),

//skip
                      // child: ElevatedButton(
                      //   onPressed: _launchURL,
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.transparent,
                      //     shadowColor: const Color.fromARGB(255, 17, 17, 17),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //   ),
                      //   child: Container(
                      //     width: double.infinity,
                      //     height: 45,
                      //     alignment: Alignment.center,
                      //     child: Text(
                      //       'Skip ',
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.w400,
                      //         fontSize: screenSize.width * 0.045,
                      //         color: Color.fromARGB(255, 181, 180, 180),
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      // child: ElevatedButton(
                      //   onPressed: _launchURL,
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.transparent,
                      //     shadowColor: const Color.fromARGB(255, 17, 17, 17),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //   ),
                      //   child: Container(
                      //     width: double.infinity,
                      //     height: 45,
                      //     alignment: Alignment.center,
                      //     child: Text(
                      //       'Contact Support',
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.w400,
                      //         fontSize: screenSize.width * 0.045,
                      //         color: Color.fromARGB(255, 181, 180, 180),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchingSection extends StatelessWidget {
  final bool enableInstructions;

  const SearchingSection({
    Key? key,
    required this.enableInstructions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12, top: screenSize.height * 0.08),
            child: const Text(
              'SEARCHING FOR AVMe...',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 17,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          if (enableInstructions)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "Check if your device is charged by double tapping the top. A green light should be blinking on the side if it's charged.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(127, 255, 255, 255),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          const Spacer(),
          Center(
            child: Image.asset(
              "assets/images/searching.png",
              width: MediaQuery.of(context).size.width * 0.9,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
