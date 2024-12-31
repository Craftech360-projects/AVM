import 'dart:developer';

import 'package:avm/backend/database/memory.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/features/memories/pages/memory_detail_page.dart';
import 'package:avm/features/memories/widgets/memory_card.dart';
import 'package:avm/features/memory/bloc/memory_bloc.dart';
import 'package:avm/pages/memories/widgets/empty_memories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        // log('state of memory ${state.memories}');
       
        return Column(
          children: List.generate(
            state.memories.length,
            (index) {
              Memory memory = state.memories[index];
              return Column(
                children: [
                  Dismissible(
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: AppColors.red.withValues(alpha: 0.5),
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
                                  style: TextStyle(color: AppColors.black),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.red,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: AppColors.white),
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
                  ),
                  if (index < state.memories.length - 1) h5,
                ],
              );
            },
          ),
        );
      },
    );
  }
}
