import 'package:capsoul/src/common_widget/dialog.dart';
import 'package:flutter/material.dart';

void showPrivacyPolicy(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        title: "Terms and Conditions",
        sections: [
          {
            'heading': "General Terms",
            'points': [
              'You must be at least 18 years old to use this app.',
              'The app is provided as-is without any warranties.',
              'We reserve the right to update the terms at any time.',
            ],
          },
          {
            'heading': "Privacy Policy",
            'points': [
              'We value your privacy and take it seriously.',
              'Personal data is only collected for app functionality.',
              'No data will be shared without user consent.',
            ],
          },
        ],
      );
    },
  );
}
