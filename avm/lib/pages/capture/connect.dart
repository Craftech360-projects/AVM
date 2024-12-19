import 'package:avm/features/capture/widgets/ripple_animation.dart';
import 'package:avm/pages/home/custom_scaffold.dart';
import 'package:avm/pages/home/page.dart';
import 'package:avm/pages/onboarding/find_device/page.dart';
import 'package:flutter/material.dart';

class ConnectDevicePage extends StatefulWidget {
  const ConnectDevicePage({super.key});

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
