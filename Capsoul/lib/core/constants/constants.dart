import 'package:capsoul/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

//Height & Width
const w4 = SizedBox(
  width: 04,
);
const w8 = SizedBox(
  width: 8,
);
const w16 = SizedBox(
  width: 16,
);
const w24 = SizedBox(
  width: 24,
);
const w32 = SizedBox(
  width: 32,
);
const h1 = SizedBox(
  height: 01,
);
const h4 = SizedBox(
  height: 4,
);
const h8 = SizedBox(
  height: 8,
);
const h16 = SizedBox(
  height: 16,
);
const h24 = SizedBox(
  height: 24,
);
const h32 = SizedBox(
  height: 32,
);

// Border Radiuses
BorderRadius br1 = BorderRadius.circular(01);
BorderRadius br2 = BorderRadius.circular(02);
BorderRadius br5 = BorderRadius.circular(05);
BorderRadius br8 = BorderRadius.circular(08);
BorderRadius br10 = BorderRadius.circular(10);
BorderRadius br12 = BorderRadius.circular(12);
BorderRadius br15 = BorderRadius.circular(15);
BorderRadius br20 = BorderRadius.circular(20);
BorderRadius br30 = BorderRadius.circular(30);

//Snackbar
void avmSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.purpleDark,
      content: Text(
        content,
        style: const TextStyle(
          fontFamily: "Montserrat",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: br8),
      padding: const EdgeInsets.symmetric(vertical: 04, horizontal: 08),
      behavior: SnackBarBehavior.floating,
      elevation: 1.5,
      margin: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 0),
      showCloseIcon: true,
      closeIconColor: AppColors.white,
    ),
  );
}
