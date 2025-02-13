import 'package:altio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

//Heights & Widths
const w4 = SizedBox(
  width: 04,
);
const w8 = SizedBox(
  width: 8,
);
const w10 = SizedBox(
  width: 10,
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

//Paddings
const pV8H8 =
    Padding(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0));
const pV10H16 =
    Padding(padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0));
const pV12H12 =
    Padding(padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0));
const pV12H16 =
    Padding(padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0));
const pV16H16 =
    Padding(padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0));
const pV16H22 =
    Padding(padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 22.0));

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
      dismissDirection: DismissDirection.startToEnd,
      backgroundColor: AppColors.purpleDark,
      content: Text(
        content,
        style: const TextStyle(
          fontFamily: "Montserrat",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 1.5,
      margin: EdgeInsets.only(
          left: 6,
          right: 6,
          bottom: MediaQuery.of(context).size.height * 0.015),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    ),
  );
}
