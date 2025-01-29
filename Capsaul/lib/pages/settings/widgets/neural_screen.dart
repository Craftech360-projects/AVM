// import 'package:capsaul/backend/database/memory.dart';
// import 'package:capsaul/backend/database/memory_provider.dart';
// import 'package:capsaul/core/theme/app_colors.dart';
// import 'package:capsaul/features/memories/bloc/memory_bloc.dart';
// import 'package:capsaul/features/memories/pages/memory_detail_page.dart';
// import 'package:capsaul/pages/home/custom_scaffold.dart';
// import 'package:flutter/material.dart';
// import 'package:graphview/graphview.dart';
// import 'dart:math';

// class NeuralScreen extends StatefulWidget {
//   const NeuralScreen({super.key});

//   @override
//   NeuralScreenState createState() => NeuralScreenState();
// }

// class NeuralScreenState extends State<NeuralScreen> {
//   final Graph graph = Graph();
//   late Algorithm builder;
//   final MemoryProvider memoryProvider = MemoryProvider();
//   late List<Memory> memories;
//   late List<String> categories;
//   late Map<String, List<Memory>> categoryMemoryMap;
//   final String _centralNodeKey = "Central";

//   @override
//   void initState() {
//     super.initState();
//     categories = [];
//     categoryMemoryMap = {};
//     _loadMemories();
//     builder = FruchtermanReingoldAlgorithm();
//   }

//   Color getCategoryColor(List<String>? categories) {
//     if (categories == null || categories.isEmpty) {
//       return AppColors.grey;
//     }
//     if (categories.contains('business')) return AppColors.blue;
//     if (categories.contains('technology')) return AppColors.green;
//     return AppColors.orange;
//   }

//   void _loadMemories() {
//     memories = memoryProvider.getMemoriesOrdered();

//     // Step 1: Extract unique categories
//     for (var memory in memories) {
//       final categoriesList = memory.structured.target?.category ?? [];
//       for (var category in categoriesList) {
//         if (!categories.contains(category)) {
//           categories.add(category);
//         }
//       }
//     }

//     // Step 2: Create a map of categories to their respective memories
//     for (var category in categories) {
//       categoryMemoryMap[category] = [];
//     }

//     for (var memory in memories) {
//       final categoriesList = memory.structured.target?.category ?? [];
//       for (var category in categoriesList) {
//         if (categoryMemoryMap.containsKey(category)) {
//           categoryMemoryMap[category]?.add(memory);
//         }
//       }
//     }

//     // Step 3: Create nodes for each category
//     for (var category in categories) {
//       final node = Node.Id(category);
//       graph.addNode(node);
//     }

//     final centralNode = Node.Id(_centralNodeKey);
//     graph.addNode(centralNode);

//     // Create edges from central node to all category nodes
//     for (var category in categories) {
//       graph.addEdge(
//         Node.Id(_centralNodeKey),
//         Node.Id(category),
//       );
//         }

//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScaffold(
//       showBackBtn: true,
//       title: Text(
//         "Capsoul Mirror",
//         style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: InteractiveViewer(
//               scaleEnabled: true,
//               panAxis: PanAxis.free,
//               panEnabled: true,
//               constrained: false,
//               boundaryMargin: EdgeInsets.all(100),
//               minScale: 0.0001,
//               maxScale: 10.6,
//               child: GraphView(
//                 animated: true,
//                 graph: graph,
//                 algorithm: builder,
//                 paint: Paint()
//                   ..color = AppColors.green
//                   ..strokeWidth = 1
//                   ..style = PaintingStyle.fill,
//                 builder: (Node node) {
//                   return GestureDetector(
//                     onTap: () {
//                       if (node.key == ValueKey(_centralNodeKey)) {
//                         // Handle tap on central node if needed
//                       } else {
//                         showCategoryDetails(context, node.key.toString());
//                       }
//                     },
//                     child: _buildNodeWidget(node),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNodeWidget(Node node) {
//     if (node.key == _centralNodeKey) {
//       return Container(
//         width: 60,
//         height: 60,
//         decoration: BoxDecoration(
//           color: AppColors.purpleDark,
//         ),
//         child: CustomPaint(
//           painter: HexagonPainter(),
//         ),
//       );
//     }

//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//       decoration: BoxDecoration(
//         color: AppColors.blue,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         node.key.toString(),
//         style: TextStyle(fontSize: 14, color: AppColors.white),
//       ),
//     );
//   }

//   void showCategoryDetails(BuildContext context, String category) {
//     List<Memory> mappedMemories = categoryMemoryMap[category] ?? [];

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(category),
//         content: SingleChildScrollView(
//           child: Column(
//             children: mappedMemories.map((memory) {
//               return ListTile(
//                 title: Text(memory.structured.target?.title ?? 'No title'),
//                 onTap: () {
//                   showMemoryDetails(context, memory);
//                 },
//               );
//             }).toList(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   void showMemoryDetails(BuildContext context, Memory memory) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MemoryDetailPage(
//           memoryAtIndex: memory.structured.target!.id,
//           memoryBloc: MemoryBloc(),
//         ),
//       ),
//     );
//   }
// }

// class HexagonPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = AppColors.purpleDark
//       ..style = PaintingStyle.fill;

//     final path = Path();
//     final centerX = size.width / 2;
//     final centerY = size.height / 2;
//     final radius = min(centerX, centerY);

//     // Create a hexagon path
//     path.moveTo(centerX + radius, centerY);
//     path.lineTo(centerX + radius/2, centerY + radius * 0.866);
//     path.lineTo(centerX - radius/2, centerY + radius * 0.866);
//     path.lineTo(centerX - radius, centerY);
//     path.lineTo(centerX - radius/2, centerY - radius * 0.866);
//     path.lineTo(centerX + radius/2, centerY - radius * 0.866);
//     path.close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }

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
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.purpleDark,
          ),
          child: Center(
            child: Text(
              userName ?? 'YOU',
              style: TextStyle(fontSize: 11, color: AppColors.white),
            ),
          ));
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.blue,
      ),
      child: Text(
        node.key.toString().replaceAll(RegExp(r'[\[\]<>]'), ''),
        style: TextStyle(fontSize: 12, color: AppColors.white),
      ),
    );
  }

  void showCategoryDetails(BuildContext context, String category) {
    List<Memory> mappedMemories = categoryMemoryMap[category] ?? [];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        titlePadding: EdgeInsets.symmetric(vertical: 08, horizontal: 12),
        contentPadding: EdgeInsets.symmetric(vertical: 06, horizontal: 12),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: br2),
        title: Text(
          category,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
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
