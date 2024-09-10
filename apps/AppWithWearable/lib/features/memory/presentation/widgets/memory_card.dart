import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/features/memory/presentation/pages/memory_detail_page.dart';
import 'package:friend_private/pages/memories/widgets/empty_memories.dart';
import 'package:intl/intl.dart';

class MemoryCardWidget extends StatelessWidget {
  const MemoryCardWidget({
    super.key,
    required MemoryBloc memoryBloc,
  }) : _memoryBloc = memoryBloc;

  final MemoryBloc _memoryBloc;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return BlocBuilder<MemoryBloc, MemoryState>(
      bloc: _memoryBloc,
      builder: (context, state) {
        print('state of memory ${state.memories}');
        if (state.memories.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 32.0),
              child: EmptyMemoriesWidget(),
            ),
          );
        }
        return SizedBox(
          height: (height - 10) * 0.38,
          child: ListView.separated(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 0),
            shrinkWrap: true,
            itemCount: state.memories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              Memory memory = state.memories[index];
              //*-- Delete Memory Card --*//
              return Dismissible(
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red.withOpacity(0.5),
                ),
                key: UniqueKey(),
                // key: Key(memory.id.toString()),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                          'Are you sure you want to delete this memory?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  _memoryBloc.add(
                    DeletedMemory(memory: memory),
                  );
                },
                //*-- GoTo Memory Detail page --*//
                child: GestureDetector(
                  onTap: () {
                    _memoryBloc.add(MemoryIndexChanged(memoryIndex: index));
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CustomMemoryDetailPage(
                          memoryBloc: _memoryBloc,
                          memoryAtIndex: index,
                        ),
                      ),
                    );
                  },
                  //*-- Memory Card --*//
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //*-- Image --*//
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(16),
                              ),
                              child: memory.memoryImg == null
                                  ? const SizedBox.shrink()
                                  : Image.memory(
                                      memory.memoryImg!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          //*-- Card Details --*//
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //*-- Date and Time --*//
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Spacer(),
                                      Text(
                                        '${DateFormat('d MMM').format(memory.createdAt)}  '
                                        '   ${DateFormat('h:mm a').format(memory.createdAt)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                memory.discarded
                                    ? const SizedBox.shrink()
                                    : const SizedBox(height: 4),
                                //*-- Title --*//
                                memory.discarded
                                    ? Text(
                                        'Discarded Memory',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                        maxLines: 1,
                                      )
                                    : Text(
                                        memory.structured.target?.title ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                        maxLines: 1,
                                      ),
                                memory.discarded
                                    ? const SizedBox.shrink()
                                    : const SizedBox(height: 8),
                                //*-- Overview --*//
                                memory.discarded
                                    ? const SizedBox.shrink()
                                    : Text(
                                        memory.structured.target?.overview ??
                                            '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: Colors.grey.shade300,
                                                height: 1.3),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                //*-- Chips --*//
                                memory.discarded
                                    ? const SizedBox.shrink()
                                    : Wrap(
                                        spacing:
                                            8.0, // Horizontal spacing between chips
                                        runSpacing:
                                            8.0, // Vertical spacing between lines
                                        children: memory
                                                .structured.target?.category
                                                .map((category) => Chip(
                                                      padding: EdgeInsets.zero,
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                      backgroundColor:
                                                          Colors.black45,
                                                      label: Text(
                                                        category,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ))
                                                .toList() ??
                                            [],
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
