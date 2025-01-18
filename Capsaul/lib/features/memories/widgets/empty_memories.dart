import 'package:capsaul/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class EmptyMemoriesWidget extends StatefulWidget {
  const EmptyMemoriesWidget({super.key});

  @override
  State<EmptyMemoriesWidget> createState() => _EmptyMemoriesWidgetState();
}

class _EmptyMemoriesWidgetState extends State<EmptyMemoriesWidget> {
  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Text(
        textAlign: TextAlign.center,
        'No memories found!\nConnect your Capsaul to create new memory',
        style: TextStyle(
            color: AppColors.greyMedium,
            fontSize: 14,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}
