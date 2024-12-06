import 'package:flutter/material.dart';
import 'package:friend_private/backend/api_requests/api/prompt.dart';
import 'package:friend_private/backend/database/prompt.dart';
import 'package:friend_private/backend/database/prompt_provider.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/core_updated/theme/app_colors.dart';
import 'package:friend_private/pages/settings/widgets/custom_textfield.dart';

class CustomPromptPage extends StatefulWidget {
  const CustomPromptPage({super.key});
  static const name = "prompt";
  @override
  State<CustomPromptPage> createState() => _CustomPromptPageState();
}

class _CustomPromptPageState extends State<CustomPromptPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _overviewController = TextEditingController();
  final TextEditingController _actionItemController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _calenderController = TextEditingController();

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final customPromptDetails = CustomPrompt(
        prompt:
            _promptController.text.isNotEmpty ? _promptController.text : null,
        title: _titleController.text.isNotEmpty ? _titleController.text : null,
        overview: _overviewController.text.isNotEmpty
            ? _overviewController.text
            : null,
        actionItems: _actionItemController.text.isNotEmpty
            ? _actionItemController.text
            : null,
        category: _categoryController.text.isNotEmpty
            ? _categoryController.text
            : null,
        calendar: _calenderController.text.isNotEmpty
            ? _calenderController.text
            : null,
      );

      PromptProvider().savePrompt(
        Prompt(
            prompt: _promptController.text,
            title: _titleController.text,
            overview: _overviewController.text,
            actionItem: _actionItemController.text,
            category: _categoryController.text,
            calender: _calenderController.text),
      );
      SharedPreferencesUtil().isPromptSaved = true;
//     SharedPreferencesUtil().saveSelectedPrompt('title', _titleController.text);
//     SharedPreferencesUtil().saveSelectedPrompt('overview', _overviewController.text);
//     SharedPreferencesUtil().saveSelectedPrompt('actionItems', _actionItemController.text);
//     SharedPreferencesUtil().saveSelectedPrompt('category', _categoryController.text);
//     SharedPreferencesUtil().saveSelectedPrompt('calendar', _calenderController.text);
      // summarizeMemory(
      //   '',
      //   [],
      //   customPromptDetails: customPromptDetails,
      // );

      print("Prompt: ${_promptController.text}");
      print("Title: ${_titleController.text}");
      print("Overview: ${_overviewController.text}");
      print("Action Items: ${_actionItemController.text}");
      print("Category: ${_categoryController.text}");
      print("Calendar: ${_calenderController.text}");

      _promptController.clear();
      _titleController.clear();
      _overviewController.clear();
      _actionItemController.clear();
      _categoryController.clear();
      _calenderController.clear();

      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFE6F5FA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 246, 253, 255),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Return to the previous screen
          },
        ),
        centerTitle: true,
        //   backgroundColor: const Color(0xFFE6F5FA),
        elevation: 0,
        title: const Text('Customize Prompt'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/bg_image.png'), // Your background image
            fit: BoxFit
                .cover, // This will ensure the image covers the entire screen
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 16),
                CustomTextField(
                  labelText: 'Title',
                  controller: _titleController,
                  maxLines: 4,
                  minLines: 4,
                  keyboardType: TextInputType.multiline,
                  hintText:
                      'The main topic or most important theme of the conversation.',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  labelText: 'Overview',
                  controller: _overviewController,
                  maxLines: 4,
                  minLines: 4,
                  keyboardType: TextInputType.multiline,
                  hintText:
                      'A detailed summary (minimum 100 words) of the key points and most significant details discussed, including decisions and major insights.',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an overview';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  labelText: 'Action',
                  controller: _actionItemController,
                  maxLines: 4,
                  minLines: 4,
                  keyboardType: TextInputType.multiline,
                  hintText:
                      'A detailed list of tasks or commitments, including the context or reason behind each task, along with who is responsible for them and any deadlines.',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter action items';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  labelText: 'Category',
                  controller: _categoryController,
                  maxLines: 4,
                  minLines: 4,
                  keyboardType: TextInputType.multiline,
                  hintText:
                      'Classify the conversation under up to 3 categories (personal, education, health, finance, legal, etc.).',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  labelText: 'Calendar',
                  controller: _calenderController,
                  maxLines: 4,
                  minLines: 4,
                  keyboardType: TextInputType.multiline,
                  hintText:
                      'Any specific events mentioned during the conversation. Include the title.',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter calendar events';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleDark,
                  ),
                  onPressed: _saveForm,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
