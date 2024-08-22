// import 'package:flutter/material.dart';
// import 'package:friend_private/backend/database/memory.dart';
// import 'package:friend_private/backend/database/memory_provider.dart';
// import 'package:friend_private/backend/mixpanel.dart';
// import 'package:friend_private/core/snackbar_util.dart';
// import 'package:friend_private/pages/memories/widgets/date_list_item.dart';

// import 'widgets/empty_memories.dart';
// import 'widgets/memory_list_item.dart';

// class MemoriesPage extends StatefulWidget {
//   final List<Memory> memories;
//   final Function refreshMemories;
//   final FocusNode textFieldFocusNode;

//   const MemoriesPage({
//     super.key,
//     required this.memories,
//     required this.refreshMemories,
//     required this.textFieldFocusNode,
//   });

//   @override
//   State<MemoriesPage> createState() => _MemoriesPageState();
// }

// class _MemoriesPageState extends State<MemoriesPage>
//     with AutomaticKeepAliveClientMixin {
//   late List<Image> imageList = [];
//   TextEditingController textController = TextEditingController();
//   FocusNode textFieldFocusNode = FocusNode();
//   bool loading = false;
//   bool displayDiscardMemories = false;

//   changeLoadingState() {
//     setState(() {
//       loading = !loading;
//     });
//   }

//   _toggleDiscardMemories() async {
//     MixpanelManager().showDiscardedMemoriesToggled(!displayDiscardMemories);
//     setState(() => displayDiscardMemories = !displayDiscardMemories);
//   }

// // If user want to deleted memory can be done by this method
// // internally calling restore method
//   void _deleteMemory(Memory memory) async {
//     MemoryProvider().deleteMemory(memory);

//     widget.refreshMemories();
//   }

// // If user want to restore deleted memory can be done by this method
//   int _restoreMemory(Memory memory) {
//     final restoredMemory = MemoryProvider().updateMemory(memory);
//     widget.refreshMemories();
//     showSnackBar(message: 'Memory Restored', context: context);
//     return restoredMemory;
//   }

//   @override
//   bool get wantKeepAlive => true;
// //! Disabled As of now
//   // void _onAddButtonPressed() {
//   //   MixpanelManager().addManualMemoryClicked();
//   //   showDialog(
//   //     context: context,
//   //     builder: (BuildContext context) {
//   //       return AddMemoryDialog(
//   //         onMemoryAdded: (Memory memory) {
//   //           widget.memories.insert(0, memory);
//   //           setState(() {});
//   //         },
//   //       );
//   //     },
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     //filtered by discarded
//     var memories = displayDiscardMemories
//         ? widget.memories
//         : widget.memories.where((memory) => !memory.discarded).toList();
//     //search the memories
//     memories = textController.text.isEmpty
//         ? memories
//         : memories
//             .where(
//               (memory) => (memory.transcript +
//                       memory.structured.target!.title +
//                       memory.structured.target!.overview)
//                   .toLowerCase()
//                   .contains(textController.text.toLowerCase()),
//             )
//             .toList();

    // var memoriesWithDates = [];
    // for (var i = 0; i < memories.length; i++) {
    //   if (i == 0) {
    //     memoriesWithDates.add(memories[i].createdAt);
    //     memoriesWithDates.add(memories[i]);
    //   } else {
    //     if (memories[i].createdAt.day != memories[i - 1].createdAt.day) {
    //       memoriesWithDates.add(memories[i].createdAt);
    //     }
    //     memoriesWithDates.add(memories[i]);
    //   }
    // }

//     return CustomScrollView(
//       slivers: [
//         const SliverToBoxAdapter(child: SizedBox(height: 32)),
//         SliverToBoxAdapter(
//           child: Container(
//             width: double.maxFinite,
//             padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
//             margin: const EdgeInsets.fromLTRB(18, 0, 18, 0),
//             decoration: BoxDecoration(
//               color: Colors.black,
//               borderRadius: const BorderRadius.all(Radius.circular(16)),
//               border: Border.all(
//                 color: Colors.grey,
//               ),
//               shape: BoxShape.rectangle,
//             ),
//             child: TextField(
//               enabled: true,
//               controller: textController,
//               onChanged: (s) {
//                 print('search $s');
//                 setState(() {});
//               },
//               obscureText: false,
//               autofocus: false,
//               focusNode: widget.textFieldFocusNode,
//               decoration: InputDecoration(
//                 hintText: 'Search for memories...',
//                 hintStyle: const TextStyle(fontSize: 14.0, color: Colors.grey),
//                 enabledBorder: InputBorder.none,
//                 focusedBorder: InputBorder.none,
//                 suffixIcon: textController.text.isEmpty
//                     ? const SizedBox.shrink()
//                     : IconButton(
//                         icon: const Icon(
//                           Icons.cancel,
//                           color: Color(0xFFF7F4F4),
//                           size: 28.0,
//                         ),
//                         onPressed: () {
//                           textController.clear();
//                           setState(() {});
//                         },
//                       ),
//               ),
//               style: TextStyle(fontSize: 14.0, color: Colors.grey.shade200),
//             ),
//           ),
//         ),
//         const SliverToBoxAdapter(child: SizedBox(height: 16)),
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // IconButton(
//                 //   onPressed: _onAddButtonPressed,
//                 //   icon: const Icon(
//                 //     Icons.add_circle_outline,
//                 //     size: 24,
//                 //     color: Colors.white,
//                 //   ),
//                 // ),
//                 const SizedBox(width: 1),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Text(
//                       displayDiscardMemories
//                           ? 'Hide Discarded'
//                           : 'Show Discarded',
//                       style: const TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       onPressed: () {
//                         _toggleDiscardMemories();
//                       },
//                       icon: Icon(
//                         displayDiscardMemories
//                             ? Icons.cancel_outlined
//                             : Icons.filter_list,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//         if (memories.isEmpty)
//           const SliverToBoxAdapter(
//             child: Center(
//               child: Padding(
//                 padding: EdgeInsets.only(top: 32.0),
//                 child: EmptyMemoriesWidget(),
//               ),
//             ),
//           )
//         else
//           SliverList(
//             delegate: SliverChildBuilderDelegate(
//               (context, index) {
//                 if (memoriesWithDates[index].runtimeType == DateTime) {
//                   return DateListItem(
//                     date: memoriesWithDates[index] as DateTime,
//                     isFirst: index == 0,
//                   );
//                 }
//                 // Delete Cards From Memory
//                 return Dismissible(
//                   key: Key(memoriesWithDates[index].id.toString()),
//                   background: Container(
//                     color: const Color.fromARGB(123, 255, 103, 103),
//                     margin: const EdgeInsets.only(top: 10),
//                     padding: const EdgeInsets.only(right: 40),
//                     child: const Icon(
//                       Icons.delete_outline_rounded,
//                       size: 50,
//                       color: Color.fromARGB(255, 255, 166, 160),
//                     ),
//                   ),
//                   direction: DismissDirection.startToEnd,
//                   onDismissed: (direction) async {
//                     _deleteMemory(memoriesWithDates[index] as Memory);
//                     await showDialog<String>(
//                       context: context,
//                       builder: (BuildContext context) => AlertDialog(
//                         title: const Text('Confirm Deletion'),
//                         content: const Text(
//                             'Are you sure you want to delete this memory?'),
//                         actions: <Widget>[
//                           TextButton(
//                             onPressed: () => {
//                               _restoreMemory(
//                                   memoriesWithDates[index] as Memory),
//                               Navigator.pop(context, 'Cancel'),
//                             },
//                             child: const Text(
//                               'Restore',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () => {
//                               Navigator.pop(context, 'OK'),
//                             },
//                             child: const Text(
//                               'Remove',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );

//                     // _deleteMemory(memoriesWithDates[index] as Memory);
//                   },
//                   child: MemoryListItem(
//                     memoryIdx: index,
//                     memory: memoriesWithDates[index] as Memory,
//                     loadMemories: widget.refreshMemories,
//                   ),
//                 );
//               },
//               childCount: memoriesWithDates.length,
//             ),
//           ),
//         const SliverToBoxAdapter(
//           child: SizedBox(height: 120),
//         ),
//       ],
//     );
//   }
// }
