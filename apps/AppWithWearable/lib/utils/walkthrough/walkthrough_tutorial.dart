import 'package:flutter/material.dart';
import 'package:friend_private/pages/settings/page.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

void onAccountCreated(BuildContext context) async {
  // bool isFirstTime = await TutorialService.isFirstTimeUser();
  // if (isFirstTime) {
  //   showTutorial(context);  // Trigger tutorial
  // TutorialService.markTutorialCompleted();  // Mark tutorial as completed
  // }
}
List<TargetFocus> targets = [];
  List<TargetFocus> settingtargets = [];
class CustomTargetFocus {
  TargetFocus buildTarget({
    required GlobalKey keyTarget,
    required String identify,
    required String titleText,
    String descriptionText = "",
    // double radius = 6.0,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
    ContentAlign contentAlign = ContentAlign.bottom,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: keyTarget,
      shape: shape,
      // radius: radius,
      contents: [
        TargetContent(
          align: contentAlign,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                titleText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  descriptionText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void showTutorial(BuildContext context, {required List<TargetFocus> targets}) {
  TutorialCoachMark(
    targets: targets,
    colorShadow: Colors.black,
    onClickTarget: (target) async {
      // print("Clicked on target: $target");
      // if (target.identify == "Target 2") {
      //   await Navigator.of(context).push(
      //     MaterialPageRoute(
      //       builder: (context) => SettingsPage(key: settingPageState),
      //     ),
      //   );

      //   showTutorial(
      //     context,
      //     targets: settingtargets,
      //   );
      // }
    },
    onClickTargetWithTapPosition: (target, tapDetails) {
      print("Target: $target");
      print(
          "Clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
    },
    onClickOverlay: (target) {
      print("Overlay clicked for target: $target");
    },
    onSkip: () {
      print("Tutorial skipped");
      return true;
    },
    onFinish: () {
      print("Tutorial finished");
    },
  ).show(context: context);
}
