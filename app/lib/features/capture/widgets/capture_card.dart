// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:friend_private/backend/database/transcript_segment.dart';
// import 'package:friend_private/backend/schema/bt_device.dart';
// import 'package:friend_private/core_updated/theme/app_colors.dart';
// import 'package:friend_private/src/core/common_widget/common_widget.dart';
// import 'package:friend_private/utils/websockets.dart';
// import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
// import 'package:tuple/tuple.dart';

// class CaptureCard extends StatelessWidget {
//   const CaptureCard({
//     super.key,
//     required this.context,
//     required this.hasTranscripts,
//     this.device,
//     required this.wsConnectionState,
//     this.internetStatus,
//     this.segments,
//     this.memoryCreating = false,
//     this.photos = const [],
//     this.scrollController,
//   });

//   final BuildContext context;
//   final bool hasTranscripts;
//   final BTDeviceStruct? device;
//   final WebsocketConnectionStatus wsConnectionState;
//   final InternetStatus? internetStatus;
//   final List<TranscriptSegment>? segments;
//   final bool memoryCreating;
//   final List<Tuple2<String, String>> photos;
//   final ScrollController? scrollController;
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;

//     return CustomCard(
//       borderRadius: 12.h + 12.h,
//       padding: EdgeInsets.all(16.h),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: const Icon(
//                 Icons.account_circle_outlined,
//                 size: 40,
//               )),
//           SizedBox(width: 8.h), // Horizontal spacing for Row
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   height: 80.h,
//                   child: AnimatedTextKit(
//                     animatedTexts: [
//                       TyperAnimatedText(
//                         device?.name != null
//                             ? '👋 Hi ${device!.name},\nChange is inevitable. '
//                                 'Always strive for the next big thing!'
//                             : '👋 Hi Guest,\nChange is inevitable. '
//                                 'Always strive for the next big thing!',
//                         textStyle: textTheme.titleMedium
//                             ?.copyWith(fontWeight: FontWeight.w400),
//                       ),
//                     ],
//                     isRepeatingAnimation: false,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 const Divider(color: AppColors.greyLight),
//                 Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//                   // Divider between sections
//                   SizedBox(height: 8.h),
//                   Text(
//                     "Check AVM Device",
//                     style: textTheme.bodySmall
//                         ?.copyWith(color: AppColors.greyLight),
//                   ),
//                   SizedBox(height: 8.h),
//                 ]),
//                 SizedBox(height: 8.h),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }