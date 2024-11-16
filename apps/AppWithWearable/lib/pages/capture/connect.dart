import 'package:flutter/material.dart';
import 'package:friend_private/pages/capture/widgets/ripple_animation.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/home/home_page_wrapper.dart';
import 'package:friend_private/pages/home/page.dart';
import 'package:friend_private/pages/onboarding/find_device/page.dart';

class ConnectDevicePage extends StatefulWidget {
  const ConnectDevicePage({super.key});
  static const name = 'connectPage';
  @override
  State<ConnectDevicePage> createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: const Text('Connect Your AVM'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RippleAnimation(
                colors: [
                  Color(0xFF9E00FF),
                  Color(0xFF5A00FF),
                  Color(0xFF3400D8)
                ],
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
              FindDevicesPage(
                goNext: () {
                  debugPrint('onConnected');
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (c) => const HomePageWrapper()),
                  );
                },
                includeSkip: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
