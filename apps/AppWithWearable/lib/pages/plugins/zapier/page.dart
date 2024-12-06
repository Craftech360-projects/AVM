import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/core_updated/theme/app_colors.dart';

class ZapierPage extends StatefulWidget {
  const ZapierPage({super.key});
  static const String name = 'zapierPage';

  @override
  State<ZapierPage> createState() => _ZapierPageState();
}

class _ZapierPageState extends State<ZapierPage> {
  bool zapierEnabled = false;
  final TextEditingController webhookController = TextEditingController();

  @override
  void initState() {
    super.initState();
    zapierEnabled = SharedPreferencesUtil().zapierEnabled;
    webhookController.text = SharedPreferencesUtil().zapierWebhookUrl ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFE6F5FA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Zapier ',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 20.h,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_image.png',
              fit: BoxFit.cover,
            ),
          ),
          // Foreground Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
            child: ListView(
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.link),
                            SizedBox(width: 16),
                            Text(
                              'Enable Zapier Integration',
                              style: TextStyle(
                                color: AppColors.blackPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: zapierEnabled,
                          onChanged: _onSwitchChanged,
                        ),
                      ],
                    ),
                  ),
                ),
                const Text(
                  'Zapier can automate workflows by connecting your app to other services. Enable to configure your integration settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                if (zapierEnabled) ..._zapierIntegrationOptions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _zapierIntegrationOptions() {
    final textTheme = Theme.of(context).textTheme;
    return [
      Container(
        margin: EdgeInsets.all(22.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.greyLavender,
          borderRadius: BorderRadius.circular(16.h),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              'Integration Options',
              style: textTheme.titleSmall?.copyWith(fontSize: 16.h),
            ),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          'Enter your Zapier webhook URL and select the type of workflows you want to automate.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        // child: TextField(
        //   controller: webhookController,
        //   decoration: const InputDecoration(
        //     labelText: 'Zapier Webhook URL',
        //     border: OutlineInputBorder(),

        //   ),
        // ),

        child: TextField(
          controller: webhookController,
          decoration: const InputDecoration(
            labelText: 'Zapier Webhook URL',
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(16.0)), // Rounded corners
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
              borderSide: BorderSide(color: AppColors.purpleBright),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
              borderSide: BorderSide(
                  color: Colors.grey), // Optional: color for enabled border
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: _saveWebhook,
        child: const Text('Save Webhook'),
      ),
      const SizedBox(height: 16),
    ];
  }

  _onSwitchChanged(bool value) async {
    SharedPreferencesUtil().zapierEnabled = value;
    if (!value) {
      SharedPreferencesUtil().zapierWebhookUrl = ''; // Clear URL when disabled
    }
    setState(() {
      zapierEnabled = value;
    });
  }

  _saveWebhook() {
    if (!zapierEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enable Zapier integration to save webhook URL.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    SharedPreferencesUtil().zapierWebhookUrl = webhookController.text;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Zapier Webhook URL saved successfully.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
