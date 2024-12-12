import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/core/constants/constants.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/features/memories/pages/memory_detail_page.dart';
import 'package:friend_private/features/memories/widgets/memory_card.dart';
import 'package:friend_private/features/memory/bloc/memory_bloc.dart';
import 'package:friend_private/pages/memories/widgets/empty_memories.dart';

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
        log('state of memory ${state.memories}');
        if (state.memories.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 32.0),
              child: EmptyMemoriesWidget(),
            ),
          );
        }
        return Expanded(
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 0),
            itemCount: state.memories.length,
            separatorBuilder: (context, index) => h10,
            itemBuilder: (context, index) {
              Memory memory = state.memories[index];
              //*-- Delete Memory Card --*//
              return Dismissible(
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.red.withOpacity(0.5),
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
