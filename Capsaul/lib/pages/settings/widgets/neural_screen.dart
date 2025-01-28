import 'package:capsaul/backend/database/memory.dart';
import 'package:capsaul/backend/database/memory_provider.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:capsaul/features/memories/bloc/memory_bloc.dart';
import 'package:capsaul/features/memories/pages/memory_detail_page.dart';
import 'package:capsaul/pages/home/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:graphview/graphview.dart';

class NeuralScreen extends StatefulWidget {
  const NeuralScreen({super.key});

  @override
  NeuralScreenState createState() => NeuralScreenState();
}

class NeuralScreenState extends State<NeuralScreen> {
  final Graph graph = Graph();
  late Algorithm builder;
  final MemoryProvider memoryProvider = MemoryProvider();
  late List<Memory> memories;
  late List<String> categories;
  late Map<String, List<Memory>> categoryMemoryMap;

  @override
  void initState() {
    super.initState();
    categories = [];
    categoryMemoryMap = {};
    _loadMemories();
    builder = FruchtermanReingoldAlgorithm();
  }

  Color getCategoryColor(List<String>? categories) {
    if (categories == null || categories.isEmpty) {
      return AppColors.grey;
    }
    if (categories.contains('business')) return AppColors.blue;
    if (categories.contains('technology')) return AppColors.green;
    return AppColors.orange;
  }

  void _loadMemories() {
    memories = memoryProvider.getMemoriesOrdered();

    // Step 1: Extract and store unique categories
    for (var memory in memories) {
      final categoriesList = memory.structured.target?.category ?? [];
      for (var category in categoriesList) {
        if (!categories.contains(category)) {
          categories.add(category);
        }
      }
    }

    // Step 2: Create a map of categories to their respective memories
    for (var category in categories) {
      categoryMemoryMap[category] = [];
    }

    for (var memory in memories) {
      final categoriesList = memory.structured.target?.category ?? [];
      for (var category in categoriesList) {
        if (categoryMemoryMap.containsKey(category)) {
          categoryMemoryMap[category]?.add(memory);
        }
      }
    }

    // Step 3: Create nodes for each category
    for (var category in categories) {
      final node = Node.Id(category);
      print('Adding node: $node');
      graph.addNode(node);
    }

    // Step 4: Create edges between category nodes and memory nodes
    for (var i = 0; i < memories.length; i++) {
      for (var j = i + 1; j < memories.length; j++) {
        if (_areMemoriesRelated(memories[i], memories[j])) {
          graph.addEdge(
            Node.Id(memories[i].id.toString()),
            Node.Id(memories[j].id.toString()),
            paint: Paint()
              ..color = AppColors.black
              ..strokeWidth = 1.0,
          );
        }
      }
    }

    setState(() {});
  }

  bool _areMemoriesRelated(Memory memory1, Memory memory2) {
    final categories1 = memory1.structured.target?.category ?? [];
    final categories2 = memory2.structured.target?.category ?? [];

    return categories1.any((category) => categories2.contains(category));
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showBackBtn: true,
      title: Text(
        "Capsoul Mirror",
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              scaleEnabled: true,
              panAxis: PanAxis.free,
              panEnabled: true,
              constrained: false,
              boundaryMargin: EdgeInsets.all(8),
              minScale: 0.001,
              maxScale: 100,
              child: GraphView(
                animated: true,
                graph: graph,
                algorithm: builder,
                paint: Paint()
                  ..color = AppColors.green
                  ..strokeWidth = 1
                  ..style = PaintingStyle.fill,
                builder: (Node node) {
                  String nodeKey = node.key.toString();
                  var memory = memories.firstWhere(
                    (memory) => memory.id.toString() == nodeKey,
                    orElse: () => Memory.empty(),
                  );

                  // If the node is a category node (not a memory node)
                  if (!memory.id.toString().contains('memory')) {
                    return GestureDetector(
                      onTap: () {
                        showCategoryDetails(context, nodeKey);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          nodeKey, // Display the category name directly
                          style:
                              TextStyle(fontSize: 14, color: AppColors.white),
                        ),
                      ),
                    );
                  }

                  return GestureDetector(
                    onTap: () {
                      showMemoryDetails(context, memory);
                    },
                    child: Container(
                      width: 100,
                      height: 40,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: getCategoryColor(
                            memory.structured.target?.category),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          Text(memory.structured.target?.title ?? 'No title'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showCategoryDetails(BuildContext context, String category) {
    List<Memory> mappedMemories = categoryMemoryMap[category] ?? [];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(category),
        content: SingleChildScrollView(
          child: Column(
            children: mappedMemories.map((memory) {
              return ListTile(
                title: Text(memory.structured.target?.title ?? 'No title'),
                onTap: () {
                  showMemoryDetails(context, memory);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void showMemoryDetails(BuildContext context, Memory memory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryDetailPage(
          memoryAtIndex: memory.structured.target!.id,
          memoryBloc: MemoryBloc(),
        ),
      ),
    );
  }
}
