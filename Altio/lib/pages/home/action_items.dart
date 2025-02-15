import 'package:altio/backend/database/memory.dart';
import 'package:altio/backend/database/memory_provider.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ActionItems extends StatefulWidget {
  const ActionItems({super.key});

  @override
  State<ActionItems> createState() => _ActionItemsState();
}

class _ActionItemsState extends State<ActionItems> {
  final memoryProvider = MemoryProvider();
  late List<ActionItem> allActionItems;
  late List<ActionItem> orderedActionItems;
  late List<ActionItem> pendingItems;

  @override
  void initState() {
    super.initState();
    _loadActionItems();
  }

  void _loadActionItems() {
    allActionItems = memoryProvider.getAllActionItems();
    orderedActionItems = memoryProvider.getActionItemsOrdered();
    pendingItems = memoryProvider.getActionItemsByStatus(false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ListView.builder(
        itemCount: orderedActionItems.length,
        itemBuilder: (context, index) {
          final item = orderedActionItems[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: br12,
              color: AppColors.purpleDark,
              boxShadow: [
                BoxShadow(
                  color: AppColors.purpleDark.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              leading: Checkbox(
                side: const BorderSide(color: AppColors.purpleDark),
                activeColor: AppColors.purpleDark,
                value: item.completed,
                fillColor: WidgetStateProperty.all(AppColors.white),
                checkColor: AppColors.purpleDark,
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      item.completed = value;
                      memoryProvider.updateActionItem(item);
                      _loadActionItems();
                    });
                  }
                },
              ),
              title: Text(
                item.description,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.white, height: 1.2),
              ),
              subtitle: item.structured.target != null
                  ? Text(
                      item.structured.target!.title,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.75),
                          height: 1.2),
                    )
                  : null,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(item.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.75),
                        ),
                  ),
                  if (item.completed)
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.green,
                    ),
                ],
              ),
            ),
          );
        },
      ),
      if (orderedActionItems.isEmpty)
        Center(
          child: Text(
            'No action items yet',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.white.withValues(alpha: 0.5)),
          ),
        ),
    ]);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
