import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/features/memory/presentation/widgets/widgets.dart';

// class MemoriesPage extends StatefulWidget {
//   const MemoriesPage({
//     super.key,
//   });

//   @override
//   State<MemoriesPage> createState() => _MemoriesPageState();
// }

// class _MemoriesPageState extends State<MemoriesPage> {
//   late MemoryBloc _memoryBloc;
//   bool _isNonDiscarded = true;
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _memoryBloc = BlocProvider.of<MemoryBloc>(context);
//     _memoryBloc.add(DisplayedMemory(isNonDiscarded: _isNonDiscarded));
//     _searchController.addListener(() {
//       _memoryBloc.add(SearchMemory(query: _searchController.text));
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         const SliverToBoxAdapter(
//           child: SizedBox(height: 32),
//         ),
//         //*--- SEARCH BAR ---*//
//         SliverToBoxAdapter(
//           child: MemorySearchWidget(
//             searchController: _searchController,
//             memoryBloc: _memoryBloc,
//           ),
//         ),
//         const SliverToBoxAdapter(
//           child: SizedBox(height: 16),
//         ),
//         //*--- FILTER DISCARDED ---*//
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Align(
//               alignment: Alignment.centerRight,
//               child: TextButton.icon(
//                 onPressed: () {
//                   setState(() {
//                     _isNonDiscarded = !_isNonDiscarded;
//                     _memoryBloc.add(
//                       DisplayedMemory(isNonDiscarded: _isNonDiscarded),
//                     );
//                   });
//                 },
//                 label: Icon(
//                   _isNonDiscarded ? Icons.cancel_outlined : Icons.filter_list,
//                   color: Colors.white,
//                 ),
//                 icon: Text(
//                   _isNonDiscarded ? 'Hide Discarded' : 'Show Discarded',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         // if (_memoryBloc.state.memories.isEmpty)
//         //   const SliverToBoxAdapter(
//         //     child: Center(
//         //       child: Padding(
//         //         padding: EdgeInsets.only(top: 32.0),
//         //         child: EmptyMemoriesWidget(),
//         //       ),
//         //     ),
//         //   )
//         // else
//         //*--- MEMORY LIST ---*//
//         SliverToBoxAdapter(
//           child: BlocConsumer<MemoryBloc, MemoryState>(
//             bloc: _memoryBloc,
//             builder: (context, state) {
//               print('>>>-${state.toString()}');
//               if (state.status == MemoryStatus.loading) {
//                 return const Center(
//                   child: CircularProgressIndicator(),
//                 );
//               } else if (state.status == MemoryStatus.failure) {
//                 return Center(
//                   child: Text(
//                     'Error: ${state.failure}',
//                   ),
//                 );
//               } else if (state.status == MemoryStatus.success) {
//                 return MemoryCardWidget(memoryBloc: _memoryBloc);
//               }
//               return const SizedBox.shrink();
//             },
//             listener: (context, state) {
//               if (state.status == MemoryStatus.failure) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Error: ${state.failure}'),
//                   ),
//                 );
//               }
//             },
//           ),
//         ),
//         const SliverToBoxAdapter(
//           child: SizedBox(height: 120),
//         ),
//       ],
//     );
//   }
// }
