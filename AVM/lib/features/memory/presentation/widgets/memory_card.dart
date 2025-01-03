import 'package:avm/backend/database/memory.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/core/widgets/custom_dialog_box.dart';
import 'package:avm/features/memories/pages/memory_detail_page.dart';
import 'package:avm/features/memories/widgets/memory_card.dart';
import 'package:avm/features/memory/bloc/memory_bloc.dart';
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
                      margin: EdgeInsets.symmetric(horizontal: 08),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        borderRadius: br12,
                        color: AppColors.red.withValues(alpha: 0.6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Delete Memory',
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          w10,
                          Icon(Icons.delete_rounded, color: AppColors.white),
                        ],
                      ),
                    ),

                    key: UniqueKey(),
                    // key: Key(memory.id.toString()),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialogWidget(
                            title: "Delete this memory",
                            message:
                                "Are you sure you want to delete this memory? This action cannot be undone!",
                            icon: Icons.delete_rounded,
                            noText: "Cancel",
                            yesText: "Delete",
                            yesPressed: () => Navigator.of(context)
                                .pop(true), // Wrap in a closure
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
                  if (index < state.memories.length - 1) h10,
                ],
              );
            },
          ),
        );
      },
    );
  }
}
