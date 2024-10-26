import 'package:flutter/material.dart';
import 'package:friend_private/backend/api_requests/api/prompt.dart';
import 'package:friend_private/backend/database/prompt.dart';
import 'package:friend_private/backend/database/prompt_provider.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/settings/widgets/custom_textfield.dart';

class CustomPromptPage extends StatefulWidget {
  const CustomPromptPage({super.key});

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

  @override
  void initState() {
    super.initState();

  
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prompts = await PromptProvider().getPrompts();
      
      if (prompts.isNotEmpty) {
        final lastPrompt = prompts.last;

        setState(() {
          _promptController.text = lastPrompt.prompt;
          _titleController.text = lastPrompt.title;
          _overviewController.text = lastPrompt.overview;
          _actionItemController.text = lastPrompt.actionItem;
          _categoryController.text = lastPrompt.category;
          _calenderController.text = lastPrompt.calender;
        });

        print('Using saved prompt');
      }
    });
  }

  void _saveForm() async {

    final customPromptDetails = CustomPrompt(
      prompt: _promptController.text.isNotEmpty ? _promptController.text : null,
      title: _titleController.text.isNotEmpty ? _titleController.text : null,
      overview: _overviewController.text.isNotEmpty ? _overviewController.text : null,
      actionItems: _actionItemController.text.isNotEmpty ? _actionItemController.text : null,
      category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
      calendar: _calenderController.text.isNotEmpty ? _calenderController.text : null,
    );

    await PromptProvider().savePrompt(
      Prompt(
        prompt: _promptController.text,
        title: _titleController.text,
        overview: _overviewController.text,
        actionItem: _actionItemController.text,
        category: _categoryController.text,
        calender: _calenderController.text,
      ),
    );

    SharedPreferencesUtil().isPromptSaved = true;

   
    _promptController.clear();
    _titleController.clear();
    _overviewController.clear();
    _actionItemController.clear();
    _categoryController.clear();
    _calenderController.clear();

    _formKey.currentState!.reset();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _titleController.dispose();
    _overviewController.dispose();
    _actionItemController.dispose();
    _categoryController.dispose();
    _calenderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Customize Prompt'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                labelText: 'Prompt',
                controller: _promptController,
                maxLines: 9,
                minLines: 9,
                keyboardType: TextInputType.multiline,
                hintText: 'Summarize the following conversation transcript. If the conversation does not contain significant insights or action items, output an empty title.',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Title',
                controller: _titleController,
                maxLines: 4,
                minLines: 4,
                keyboardType: TextInputType.multiline,
                hintText: 'The main topic or most important theme of the conversation.',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Overview',
                controller: _overviewController,
                maxLines: 4,
                minLines: 4,
                keyboardType: TextInputType.multiline,
                hintText: 'A detailed summary (minimum 100 words) of the key points and most significant details discussed, including decisions and major insights.',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Action',
                controller: _actionItemController,
                maxLines: 4,
                minLines: 4,
                keyboardType: TextInputType.multiline,
                hintText: 'A detailed list of tasks or commitments, including the context or reason behind each task, along with who is responsible for them and any deadlines.',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Category',
                controller: _categoryController,
                maxLines: 4,
                minLines: 4,
                keyboardType: TextInputType.multiline,
                hintText: 'Classify the conversation under up to 3 categories (personal, education, health, finance, legal, etc.).',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Calendar',
                controller: _calenderController,
                maxLines: 4,
                minLines: 4,
                keyboardType: TextInputType.multiline,
                hintText: 'Any specific events mentioned during the conversation. Include the title.',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                onPressed: _saveForm,
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
