
import 'package:flutter/material.dart';
import 'package:friend_private/utils/walkthrough/walkthrough_tutorial.dart';

void captureWalkThrough(
    {required GlobalKey capturekey, required GlobalKey searchKey}) {
  targets.add(
    CustomTargetFocus().buildTarget(
      keyTarget: capturekey,
      identify: "Target 1",
      titleText: "Memory Creation",
      descriptionText: "Swipe for instant creation -> ->",
    ),
  );

  targets.add(
    CustomTargetFocus().buildTarget(
      keyTarget: searchKey,
      identify: "Target 2",
      titleText: "Search the memory",
    ),
  );
}
