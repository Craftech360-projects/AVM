import 'package:capsaul/src/common_widget/dialog.dart';
import 'package:flutter/material.dart';

void showPrivacyPolicy(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        title: "Privacy Policy",
        sections: [
          {
            'heading': "Introduction",
            'points': [
              "Welcome to Altio Capsaul's privacy policy. At Altio Capsaul, we are committed to protecting your privacy and ensuring the security of your personal information. This privacy policy explains how our app and wearable device, Capsaul, collect, use, and safeguard your data.",
            ],
          },
        ],
      );
    },
  );
}
