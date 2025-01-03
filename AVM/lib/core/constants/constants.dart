import 'package:avm/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

//Height & Width
const w5 = SizedBox(
  width: 05,
);
const w10 = SizedBox(
  width: 10,
);
const w15 = SizedBox(
  width: 15,
);
const w20 = SizedBox(
  width: 20,
);
const w30 = SizedBox(
  width: 30,
);
const h1 = SizedBox(
  height: 01,
);
const h5 = SizedBox(
  height: 05,
);
const h10 = SizedBox(
  height: 10,
);
const h15 = SizedBox(
  height: 15,
);
const h20 = SizedBox(
  height: 20,
);
const h30 = SizedBox(
  height: 30,
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
      margin: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 16),
      showCloseIcon: true,
      closeIconColor: AppColors.white,
    ),
  );
}
