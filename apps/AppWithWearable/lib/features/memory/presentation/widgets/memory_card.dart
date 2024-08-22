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
    return BlocBuilder<MemoryBloc, MemoryState>(
      bloc: _memoryBloc,
      builder: (context, state) {
        if (state.memories.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 32.0),
              child: EmptyMemoriesWidget(),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: state.memories.length,
          itemBuilder: (context, index) {
            Memory memory = state.memories[index];
            return Dismissible(
              key: Key(memory.id.toString()),
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
              child: GestureDetector(
                // onTap: () =>
                onTap: () {
                  _memoryBloc.add(MemoryIndexChanged(memoryIndex: index));
                  Navigator.of(context).push(
                    // MaterialPageRoute(
                    //   builder: (context) => MemoryDetailPage(
                    //     memory: memory,
                    //   ),
                    // ),
                    MaterialPageRoute(
                      builder: (context) => CustomMemoryDetailPage(
                        memoryBloc: _memoryBloc,
                        memoryAtIndex: index,
                      ),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 150,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            memory.discarded
                                ? const SizedBox.shrink()
                                : const SizedBox(height: 8),
                            memory.discarded
                                ? const SizedBox.shrink()
                                : Text(
                                    memory.structured.target?.title ?? '',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                    maxLines: 1,
                                  ),
                            memory.discarded
                                ? const SizedBox.shrink()
                                : const SizedBox(height: 8),
                            memory.discarded
                                ? const SizedBox.shrink()
                                : Text(
                                    memory.structured.target?.overview ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Colors.grey.shade300,
                                            height: 1.3),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            const SizedBox(height: 8),
                            const Divider(
                              height: 0,
                              thickness: 1,
                            ),
                            Row(
                              children: [
                                Text(
                                  'Created At: ${DateFormat('EE d MMM h:mm a').format(memory.createdAt)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const Spacer(),
                                IconButton(
                                  visualDensity:
                                      const VisualDensity(vertical: -4),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    debugPrint('memory_list_item.dart');
                                  },
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
