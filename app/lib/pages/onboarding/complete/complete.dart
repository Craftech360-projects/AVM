// import 'package:flutter/material.dart';
// import 'package:friend_private/core/theme/app_colors.dart';
// import 'package:friend_private/src/common_widget/elevated_button.dart';

// class CompletePage extends StatefulWidget {
//   final VoidCallback goNext;

//   const CompletePage({super.key, required this.goNext});

//   @override
//   State<CompletePage> createState() => _CompletePageState();
// }

// class _CompletePageState extends State<CompletePage> {
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     return Column(
//       //improve UI on smaller devices
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         const SizedBox(height: 40),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Row(
//             children: [
//               Expanded(
//                 child: CustomElevatedButton(
//                   // padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                   onPressed: widget.goNext,
//                   child: Text(
//                     'Get Started',
//                     style:
//                         textTheme.titleMedium?.copyWith(color: AppColors.white),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         // ElevatedButton()
//       ],
//     );
//   }
// }
