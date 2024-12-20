import 'package:avm/backend/preferences.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/pages/home/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ZapierPage extends StatefulWidget {
  const ZapierPage({super.key});

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
    webhookController.text = SharedPreferencesUtil().zapierWebhookUrl;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showBackBtn: true,
      showGearIcon: true,
      title: const Center(
        child: Text(
          "Zapier Options",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.greyLavender,
                      child: Icon(Icons.link),
                    ),
                    w15,
                    Text(
                      'Zapier Integration',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
          h5,
          const Text(
            'Zapier can automate workflows by connecting your app to other services. Enable to configure your integration settings.',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: AppColors.greyMedium,
            ),
          ),
          h20,
          if (zapierEnabled) ..._zapierIntegrationOptions(),
        ],
      ),
    );
  }

  _zapierIntegrationOptions() {
    final textTheme = Theme.of(context).textTheme;
    return [
      Container(
        margin: EdgeInsets.symmetric(vertical: 12.0),
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.greyLavender,
          borderRadius: br12,
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
      Text(
        'Enter your Zapier webhook URL and select the type of workflows you want to automate.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.grey,
        ),
      ),
      h20,
      TextField(
        textAlign: TextAlign.center,
        controller: webhookController,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: br12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: br12,
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          hintText: "Zapier Webhook URL",
          border: OutlineInputBorder(
            borderRadius: br12,
          ),
        ),
      ),
      h15,
      ElevatedButton(
        onPressed: _saveWebhook,
        child: const Text(
          'Save Webhook',
          style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
              fontSize: 17),
        ),
      ),
      h15,
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
      avmSnackBar(context, "Enable Zapier integration to save webhook URL.");

      return;
    }
    SharedPreferencesUtil().zapierWebhookUrl = webhookController.text;
    avmSnackBar(context, "Zapier Webhook URL saved successfully.");
  }
}
