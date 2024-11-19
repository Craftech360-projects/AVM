// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:friend_private/src/core/common_widget/common_widget.dart';
// import 'package:friend_private/src/core/constant/constant.dart';

// class CaptureCard extends StatelessWidget {
//   const CaptureCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     return CustomCard(
//       borderRadius: 40.h + 12.h,
//       padding: EdgeInsets.all(12.h),
//       child: Expanded(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(40.h),
//               child: Image.asset(
//                 IconImage.avmdevice,
//                 height: 150.h,
//                 width: double.infinity,
//                 fit: BoxFit.fitWidth,
//               ),
//             ),
//             SizedBox(height: 8.h),
//             SizedBox(
//               height: 80.h,
//               child: AnimatedTextKit(
//                 animatedTexts: [
//                   TyperAnimatedText(
//                     '👋Hi! Joe,\nChange is inevitable. '
//                     'Always strive for the next big thing.!',
//                     textStyle: textTheme.titleMedium
//                         ?.copyWith(fontWeight: FontWeight.w400),
//                   ),
//                 ],
//                 isRepeatingAnimation: false,
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               "Check AVM Device",
//               style:
//                   textTheme.bodySmall?.copyWith(color: CustomColors.greyLight),
//             ),
//             Row(
//               children: [
//                 Container(
//                   width: 8.h,
//                   height: 8.w,
//                   decoration: const BoxDecoration(
//                     color: CustomColors.yellowAccent,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 SizedBox(width: 4.h),
//                 Text(
//                   "Disconnected",
//                   style: textTheme.bodySmall
//                       ?.copyWith(color: CustomColors.greyLight, fontSize: 10.h),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8.h),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/utils/websockets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tuple/tuple.dart';

class CaptureCard extends StatelessWidget {
  const CaptureCard({
    super.key,
    required this.context,
    required this.hasTranscripts,
    this.device,
    required this.wsConnectionState,
    this.internetStatus,
    this.segments,
    this.memoryCreating = false,
    this.photos = const [],
    this.scrollController,
  });

  final BuildContext context;
  final bool hasTranscripts;
  final BTDeviceStruct? device;
  final WebsocketConnectionStatus wsConnectionState;
  final InternetStatus? internetStatus;
  final List<TranscriptSegment>? segments;
  final bool memoryCreating;
  final List<Tuple2<String, String>> photos;
  final ScrollController? scrollController;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomCard(
      borderRadius: 40.h + 12.h,
      padding: EdgeInsets.all(12.h),
      child: Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40.h),
              child: Image.asset(
                IconImage.avmdevice,
                height: 150.h,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 80.h,
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    '👋Hi! Joe,\nChange is inevitable. '
                    'Always strive for the next big thing!',
                    textStyle: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w400),
                  ),
                ],
                isRepeatingAnimation: false,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Check AVM Device",
              style:
                  textTheme.bodySmall?.copyWith(color: CustomColors.greyLight),
            ),
            Row(
              children: [
                Container(
                  width: 8.h,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: CustomColors.yellowAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.h),
                Text(
                  wsConnectionState == 'connected'
                      ? "Connected"
                      : "Disconnected",
                  style: textTheme.bodySmall
                      ?.copyWith(color: CustomColors.greyLight, fontSize: 10.h),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // Display dynamic data from incoming parameters like device or internet status
            // Text(
            //   "Device: $device",
            //   style:
            //       textTheme.bodySmall?.copyWith(color: CustomColors.greyLight),
            // ),
            // SizedBox(height: 4.h),
            // Text(
            //   "Internet Status: $internetStatus",
            //   style:
            //       textTheme.bodySmall?.copyWith(color: CustomColors.greyLight),
            // ),
            // SizedBox(height: 4.h),
            // Text(
            //   "Segments: ${segments.join(", ")}", // Example of displaying the segments list
            //   style:
            //       textTheme.bodySmall?.copyWith(color: CustomColors.greyLight),
            // ),
            // SizedBox(height: 4.h),
            // Text(
            //   "Memory Creating: ${memoryCreating ? 'Yes' : 'No'}",
            //   style:
            //       textTheme.bodySmall?.copyWith(color: CustomColors.greyLight),
            // ),
            //SizedBox(height: 8.h),
            // You can display photos or use them in a gallery
            // photos.isNotEmpty
            //     ? Container(
            //         height: 100.h,
            //         child: ListView.builder(
            //           controller: scrollController,
            //           scrollDirection: Axis.horizontal,
            //           itemCount: photos.length,
            //           itemBuilder: (context, index) {
            //             return Padding(
            //               padding: EdgeInsets.only(right: 8.h),
            //               child: ClipRRect(
            //                 borderRadius: BorderRadius.circular(12.h),
            // child: Image.network(
            //   photos[index],
            //   width: 100.h,
            //   height: 100.h,
            //   fit: BoxFit.cover,
            // ),
            //               ),
            //             );
            //           },
            //         ),
            //       )
            // : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
