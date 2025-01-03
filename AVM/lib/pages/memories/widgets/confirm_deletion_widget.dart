import 'package:avm/backend/database/memory.dart';
import 'package:avm/backend/database/memory_provider.dart';
import 'package:avm/backend/mixpanel.dart';
import 'package:avm/widgets/custom_dialog_box.dart';
import 'package:flutter/material.dart';

class ConfirmDeletionWidget extends StatefulWidget {
  final Memory memory;
  final VoidCallback? onDelete;

  const ConfirmDeletionWidget({
    super.key,
    required this.memory,
    required this.onDelete,
  });

  @override
  State<ConfirmDeletionWidget> createState() => _ConfirmDeletionWidgetState();
}

class _ConfirmDeletionWidgetState extends State<ConfirmDeletionWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialogWidget(
      title: "Delete memory",
      message: "Are you sure you want to delete this memory?",
      icon: Icons.delete_rounded,
      yesPressed: () async {

        MemoryProvider().deleteMemory(widget.memory);
        Navigator.pop(context);
        widget.onDelete?.call();
        MixpanelManager().memoryDeleted(widget.memory);
      },
    );
  }
}
  