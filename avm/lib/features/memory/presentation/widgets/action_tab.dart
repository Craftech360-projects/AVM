import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avm/backend/database/memory_provider.dart';
import 'package:avm/backend/mixpanel.dart';
import 'package:avm/features/memory/bloc/memory_bloc.dart';

class ActionTab extends StatefulWidget {
  const ActionTab(
      {super.key,
      required this.memoryAtIndex,
      required this.memoryBloc,
      required this.pageController});
  final int memoryAtIndex;
  final MemoryBloc memoryBloc;
  final PageController pageController;

  @override
  State<ActionTab> createState() => _ActionTabState();
}

class _ActionTabState extends State<ActionTab> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoryBloc, MemoryState>(
      builder: (context, state) {
        final selectedMemory = state.memories[state.memoryIndex];
        final structured = state.memories[state.memoryIndex].structured.target!;

        if (state.status == MemoryStatus.success) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  structured.actionItems.isNotEmpty
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Action Items',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(fontSize: 26),
                            ),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text:
                                        '- ${structured.actionItems.map((e) => e.description).join('\n- ')}'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content:
                                      Text('Action items copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                ));
                                MixpanelManager().copiedMemoryDetails(
                                    selectedMemory,
                                    source: 'Action Items');
                              },
                              icon: const Icon(Icons.copy_rounded,
                                  color: Colors.white, size: 20),
                            )
                          ],
                        )
                      : const SizedBox(
                          height: 400,
                          child: Center(
                              child:
                                  Text("Oops! This Memory Don't have Action")),
                        ),
                  ...structured.actionItems.map<Widget>(
                    (item) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              item.completed = !item.completed;
                              MemoryProvider().updateActionItem(item);
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            color: item.completed ? Colors.green : Colors.grey,
                            item.completed
                                ? Icons.task_alt
                                : Icons.circle_outlined,
                            size: 20,
                          ),
                          title: Text(
                            item.description,
                            style: TextStyle(
                              decoration: item.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: Colors.grey.shade300,
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
