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

// AppBar commonAppBar(
//   BuildContext context, {
//   dynamic widget,
//   String? title,
//   bool showBackBtn = false,
//   bool showGearIcon = false,
//   bool showBatteryLevel = true,
//   bool showDateTime = true,
// }) {
//   return AppBar(
//     backgroundColor: AppColors.white,
//     elevation: 0,
//     leading: showBackBtn
//         ? IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.arrow_back_ios_new_rounded))
//         : null,
//     title: showDateTime
//         ? Text(title!,
//             style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.greyMedium))
//         : null,
//     actions: [
//       if (showBatteryLevel) BatteryIndicator(batteryLevel: widget.batteryLevel),
//       w5,
//       if (showGearIcon)
//         GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => SettingPage(
//                     device: widget.device, batteryLevel: widget.batteryLevel),
//               ),
//             );
//           },
//           child: CircleAvatar(
//             backgroundColor: AppColors.white,
//             child: CustomIconButton(
//               size: 24.h,
//               iconPath: AppImages.gearIcon,
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => SettingPage(
//                         device: widget.device,
//                         batteryLevel: widget.batteryLevel),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       w10
//     ],
//   );
// }

//Snackbar
void avmSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color.fromARGB(255, 226, 199, 252),
      content: Text(
        content,
        style: const TextStyle(
          fontFamily: "Montserrat",
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: br12),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
      behavior: SnackBarBehavior.floating,
      elevation: 1.5,
      margin: const EdgeInsets.only(left: 18, top: 0, right: 18, bottom: 22),
      showCloseIcon: true,
      closeIconColor: AppColors.black,
    ),
  );
}
