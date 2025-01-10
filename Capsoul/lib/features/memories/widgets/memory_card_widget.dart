import 'dart:developer';

import 'package:capsoul/backend/database/memory.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:capsoul/core/widgets/custom_dialog_box.dart';
import 'package:capsoul/features/memories/bloc/memory_bloc.dart';
import 'package:capsoul/features/memories/pages/memory_detail_page.dart';
import 'package:capsoul/features/memories/widgets/empty_memories.dart';
import 'package:capsoul/features/memories/widgets/memory_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemoryCardWidget extends StatelessWidget {
  const MemoryCardWidget({
    super.key,
    required this.memoryBloc,
  });

  final MemoryBloc memoryBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoryBloc, MemoryState>(
      bloc: memoryBloc,
      builder: (context, state) {
        if (state.memories.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 38.0),
              child: EmptyMemoriesWidget(),
            ),
          );
        }

        bool isAnyMemorySelected = state.selectedMemories.contains(true);

        return Column(
          children: [
            if (isAnyMemorySelected)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    print(
                        'Delete button clicked. Selected memories:===> ${state.selectedMemories}');
                    memoryBloc.add(BatchDeleteMemory());
                  },
                  icon: Icon(
                    Icons.delete,
                    color: AppColors.red,
                  ),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: AppColors.red),
                  ),
                ),
              ),
            Column(
              children: List.generate(
                state.memories.length,
                (index) {
                  // if (index >= state.selectedMemories.length) {
                  //   state.selectedMemories.add(false);
                  // }

                  Memory memory = state.memories[index];
                  bool isSelected = state.selectedMemories[index];

                  return GestureDetector(
                    onLongPress: () {
                      List<bool> updatedSelection =
                          List.from(state.selectedMemories);
                      // updatedSelection[index] = !updatedSelection[index];
                      updatedSelection[index] = !isSelected;
                      memoryBloc.add(UpdatedSelection(updatedSelection));
                      log('Memory at index $index selected: ${updatedSelection[index]}');
                    },
                    child: Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.red.withOpacity(0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Delete Memory',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.delete_rounded, color: AppColors.white),
                          ],
                        ),
                      ),
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
                              yesPressed: () => Navigator.of(context).pop(true),
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        memoryBloc.add(DeletedMemory(memory: memory));
                      },
                      child: GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            List<bool> updatedSelection =
                                List.from(state.selectedMemories);
                            updatedSelection[index] = false;
                            memoryBloc.add(UpdatedSelection(updatedSelection));
                          } else {
                            memoryBloc
                                .add(MemoryIndexChanged(memoryIndex: index));
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MemoryDetailPage(
                                  memoryBloc: memoryBloc,
                                  memoryAtIndex: index,
                                ),
                              ),
                            );
                          }
                        },
                        child: MemoryCard(
                          memory: memory,
                          isSelected: isSelected,
                          onSelect: () {
                            List<bool> updatedSelection =
                                List.from(state.selectedMemories);
                            updatedSelection[index] = !isSelected;
                            memoryBloc.add(UpdatedSelection(updatedSelection));
                            print(
                                'Memory at index $index selected via checkbox:===> ${updatedSelection[index]}');
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
