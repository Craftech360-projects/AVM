import 'package:capsaul/backend/preferences.dart';
import 'package:capsaul/core/assets/app_images.dart';
import 'package:capsaul/core/constants/constants.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:capsaul/pages/home/custom_scaffold.dart';
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
        child: Center(
          child: Text(
            "Zapier Options",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    w16,
                    Text(
                      'Zapier Integration',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ],
                ),
                Switch(
                  inactiveTrackColor: AppColors.white,
                  activeTrackColor: AppColors.purpleDark,
                  activeColor: AppColors.commonPink,
                  activeThumbImage: AssetImage(AppImages.appLogo),
                  value: zapierEnabled,
                  onChanged: _onSwitchChanged,
                ),
              ],
            ),
          ),
          h4,
          const Text(
            'Zapier can automate workflows by connecting your app to other services. Enable to configure your integration settings.',
            textAlign: TextAlign.center,
          ),
          h16,
          if (zapierEnabled) ..._zapierIntegrationOptions(),
        ],
      ),
    );
  }

  _zapierIntegrationOptions() {
    final textTheme = Theme.of(context).textTheme;
    return [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: AppColors.commonPink,
          borderRadius: br8,
        ),
        child: Text(
          textAlign: TextAlign.center,
          'Integration Options',
          style: textTheme.titleSmall?.copyWith(fontSize: 16.h),
        ),
      ),
      Text(
        'Enter your Zapier webhook URL and select the type of workflows you want to automate.',
        textAlign: TextAlign.start,
      ),
      h16,
      TextField(
        textAlign: TextAlign.center,
        controller: webhookController,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: br8,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: br8,
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          hintText: "Zapier Webhook URL",
          border: OutlineInputBorder(
            borderRadius: br8,
          ),
        ),
      ),
      h16,
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purpleDark,
          shape: RoundedRectangleBorder(
            borderRadius: br8,
          ),
        ),
        onPressed: _saveWebhook,
        child: const Text(
          'Save Webhook',
          style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16),
        ),
      ),
    ];
  }

  _onSwitchChanged(bool value) async {
    SharedPreferencesUtil().zapierEnabled = value;
    if (!value) {
      SharedPreferencesUtil().zapierWebhookUrl = '';
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
