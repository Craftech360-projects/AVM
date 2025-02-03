import 'package:capsaul/backend/database/memory.dart';
import 'package:capsaul/backend/database/memory_provider.dart';
import 'package:capsaul/backend/preferences.dart';
import 'package:capsaul/core/constants/constants.dart';
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
  final String _centralNodeKey = "Central";
  String? userName = '';

  final buttonLabels = [
    'Business',
    'Technology',
    'Health',
    'Science',
    'Entertainment',
    'Sports',
  ];

  @override
  void initState() {
    super.initState();
    categories = [];
    categoryMemoryMap = {};
    builder = FruchtermanReingoldAlgorithm();
    _loadMemories();
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
    final name = SharedPreferencesUtil().givenName;

    // Step 1: Extract unique categories
    for (var memory in memories) {
      final categoriesList = memory.structured.target?.category ?? [];
      for (var category in categoriesList) {
        String cleanedCategory =
            category.replaceAll(RegExp(r'[\[\]<>]'), '').trim();
        if (!categories.contains(cleanedCategory)) {
          categories.add(cleanedCategory);
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
        String cleanedCategory =
            category.replaceAll(RegExp(r'[\[\]<>]'), '').trim();
        if (categoryMemoryMap.containsKey(cleanedCategory)) {
          categoryMemoryMap[cleanedCategory]?.add(memory);
        }
      }
    }

    // Step 3: Create nodes for each category
    graph.addNode(Node.Id(_centralNodeKey));
    for (var category in categories) {
      graph.addNode(Node.Id(category));
    }

    // Create edges from central node to all category nodes
    for (var category in categories) {
      graph.addEdge(
        Node.Id(_centralNodeKey),
        Node.Id(category),
      );
    }

    // Force the algorithm to run
    // builder.init(graph);
    // builder.run(graph, 800.0, 50.0);
    setState(() {
      userName = name;
    });
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
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            height: 35,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: buttonLabels.length,
              separatorBuilder: (context, index) => w8,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shadowColor: AppColors.black,
                    elevation: 1,
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.black,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontFamily: "Montserrat",
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: br5,
                      side: BorderSide(color: AppColors.black, width: 1),
                    ),
                  ),
                  child: Text(buttonLabels[index]),
                );
              },
            ),
          ),
          Divider(
            color: AppColors.black,
            thickness: 0.8,
          ),
          Expanded(
            child: InteractiveViewer(
              scaleEnabled: true,
              panAxis: PanAxis.free,
              panEnabled: true,
              constrained: false,
              boundaryMargin: EdgeInsets.all(100),
              minScale: 0.0001,
              maxScale: 10.6,
              child: GraphView(
                animated: true,
                graph: graph,
                algorithm: builder,
                paint: Paint()
                  ..color = AppColors.green
                  ..strokeWidth = 1
                  ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  return GestureDetector(
                    onTap: () {
                      if (node.key == ValueKey(_centralNodeKey)) {
                      } else {
                        showCategoryDetails(context, node.key.toString());
                      }
                    },
                    child: _buildNodeWidget(node),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeWidget(Node node) {
    if (node.key != null && node.key?.value == _centralNodeKey) {
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: AppColors.purpleDark,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              textAlign: TextAlign.center,
              userName ?? 'YOU',
              style: TextStyle(fontSize: 11, color: AppColors.white),
            ),
          ));
    }

    return Container(
      alignment: Alignment.center,
      width: 80,
      height: 80,
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.blue,
      ),
      child: Text(
        textAlign: TextAlign.center,
        node.key.toString().replaceAll(RegExp(r'[\[\]<>]'), ''),
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.white),
      ),
    );
  }

  void showCategoryDetails(BuildContext context, String category) {
    String cleanedCategory =
        category.replaceAll(RegExp(r'[\[\]<>]'), '').trim();
    List<Memory> mappedMemories = categoryMemoryMap[cleanedCategory] ?? [];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        titlePadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        contentPadding: EdgeInsets.symmetric(vertical: 08, horizontal: 12),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: br5),
        title: Text(cleanedCategory.toUpperCase(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content: SingleChildScrollView(
          child: Column(
            children: mappedMemories.map((memory) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: AppColors.black, width: 0.5),
                      borderRadius: br8),
                  title: Text(
                    memory.structured.target?.title ?? 'No title',
                    style: TextStyle(
                        color: AppColors.black,
                        fontSize: 13.5,
                        letterSpacing: 0),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MemoryDetailPage(
                          memoryAtIndex: 1,
                          memoryBloc: MemoryBloc(),
                        ),
                      ),
                    );
                    // showMemoryDetails(context, memory);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void showMemoryDetails(BuildContext context, Memory memory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryDetailPage(
          memoryAtIndex: memory.id,
          memoryBloc: MemoryBloc(),
        ),
      ),
    );
  }
}
