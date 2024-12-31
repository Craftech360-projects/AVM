// Copyright (c) 2023 Larry Aasen. All rights reserved.

import 'package:avm/backend/mixpanel.dart';
import 'package:avm/core/widgets/custom_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class MyUpgrader extends Upgrader {
  MyUpgrader({super.debugLogging, super.debugDisplayOnce});
}

class MyUpgradeAlert extends UpgradeAlert {
  MyUpgradeAlert({
    super.key,
    super.upgrader,
    super.child,
    super.dialogStyle,
  });

  @override
  UpgradeAlertState createState() => MyUpgradeAlertState();
}

class MyUpgradeAlertState extends UpgradeAlertState {
  @override
  void showTheDialog({
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogWidget(
            title: "New version Available",
            message: "A new version of Altio is available to download.",
            icon: Icons.download_rounded,
            noText: "Not now",
            yesText: "Update",
            yesPressed: () {
              onUserUpdated(context, !widget.upgrader.blocked());
              MixpanelManager().upgradeModalClicked();
            });
      },
    );
  }
}
