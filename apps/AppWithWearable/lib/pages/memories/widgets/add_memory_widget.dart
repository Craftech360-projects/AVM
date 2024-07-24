import 'package:flutter/material.dart';
import 'package:AVMe/backend/database/memory.dart';
import 'package:AVMe/backend/mixpanel.dart';
import 'package:AVMe/backend/storage/memories.dart';
import 'package:AVMe/utils/memories.dart';

class AddMemoryDialog extends StatefulWidget {
  final Function(Memory) onMemoryAdded;

  const AddMemoryDialog({super.key, required this.onMemoryAdded});

  @override
  _AddMemoryDialogState createState() => _AddMemoryDialogState();
}

class _AddMemoryDialogState extends State<AddMemoryDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _actionItemControllers = [];
  final ScrollController _scrollController = ScrollController();

  void _addActionItem() {
    setState(() {
      _actionItemControllers.add(TextEditingController());
    });

    // Scroll to the bottom to make the newly added item visible
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _removeActionItem(int index) {
    setState(() {
      _actionItemControllers.removeAt(index);
    });
  }

  void _onSaveButtonPressed() async {
    String title = _titleController.text;
    String description = _descriptionController.text;
    List<String> actionItems =
        _actionItemControllers.map((controller) => controller.text).toList();
    Memory created = await finalizeMemoryRecord(
      '',
      MemoryStructured(
        actionItems: actionItems,
        pluginsResponse: [],
        title: title,
        overview: description,
      ),
      null,
      null,
      null,
    );
    widget.onMemoryAdded(created);
    MixpanelManager().manualMemoryCreated(created);
    debugPrint('Memory created: ${created.id}');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            margin: const EdgeInsets.only(top: 12, left: 8, right: 8),
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Color.fromARGB(95, 132, 113, 159),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: Color.fromARGB(95, 132, 113, 159),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add Memory',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color.fromARGB(95, 132, 113, 159),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color.fromARGB(95, 132, 113, 159),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Overview',
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Action Items',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: constraints.maxHeight -
                            180, // Adjust this value as needed
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _actionItemControllers.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  95, 132, 113, 159),
                                              width: 1,
                                            ),
                                          ),
                                          child: TextField(
                                            controller:
                                                _actionItemControllers[index],
                                            style: const TextStyle(
                                                color: Colors.white),
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Action item ${index + 1}',
                                              hintStyle: const TextStyle(
                                                  color: Colors.white70),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (index > 0)
                                        IconButton(
                                          onPressed: () =>
                                              _removeActionItem(index),
                                          icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.pink),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            TextButton.icon(
                              onPressed: _addActionItem,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text('Add Action Item',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _onSaveButtonPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
