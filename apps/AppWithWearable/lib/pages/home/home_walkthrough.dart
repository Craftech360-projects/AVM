import 'package:flutter/material.dart';
import 'package:friend_private/utils/walkthrough/walkthrough_tutorial.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

void homeWalkThrough(
    {required GlobalKey capturekey,required GlobalKey chatNavKey}) {
  targets.add(
    CustomTargetFocus().buildTarget(
      keyTarget: capturekey,
      identify: "Target 3",
      titleText: "Bluetooth connection",
      descriptionText: "Pair your AVM device",
      shape:ShapeLightFocus.Circle
    ),
  );
  targets.add(
    CustomTargetFocus().buildTarget(
      keyTarget: chatNavKey,
      identify: "Target 4",
      titleText: "AI based Chat System",
      descriptionText: "All your daily task ask AI",
      shape:ShapeLightFocus.Circle,
      contentAlign: ContentAlign.top
    ),
  );
}
