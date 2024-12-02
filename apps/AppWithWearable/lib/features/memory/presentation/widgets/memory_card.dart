import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/pages/memories/widgets/empty_memories.dart';
import 'package:friend_private/src/features/home/presentation/widgets/widgets.dart';
import 'package:friend_private/src/features/memories/presentation/pages/memory_detail_page.dart';

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
          height: (height - 5) * 0.48,
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
                              style: TextStyle(color: Colors.black),
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
                        builder: (context) => MemoryDetailPage(
                          memoryBloc: _memoryBloc,
                          memoryAtIndex: index,
                        ),
                      ),
                    );
                  },
                  //*-- Memory Card --*//
                  child: MemoryCard(memory: memory),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
