import 'package:friend_private/backend/database/box.dart';
import 'package:friend_private/backend/database/prompt.dart';
import 'package:objectbox/objectbox.dart';

class PromptProvider {
  static final PromptProvider _instance = PromptProvider._internal();
  static final Box<Prompt> _box = ObjectBoxUtil().box!.store.box<Prompt>();

  factory PromptProvider() {
    return _instance;
  }

  PromptProvider._internal();

  // Method to update a Prompt
  int updatePrompt(Prompt prompt) => _box.put(prompt);

  // Method to get all Prompts
  List<Prompt> getPrompts() => _box.getAll();

  // Method to get Prompts count
  int getPromptsCount() => _box.count();

  // Method to get a Prompt by ID
  Prompt? getPromptById(int id) => _box.get(id);

  // Method to save a Prompt
  int savePrompt(Prompt prompt) {
    try {
      // Debugging output
      print("Saving Prompt with ID: ${prompt.id}");
      // print("Prompt Details: ${promptToString(prompt)}");

      // Save the prompt
      int id = _box.put(prompt);

      print("Prompt saved with ID: $id");

      return id;
    } catch (e) {
      print("Error saving Prompt: $e");
      return -1; // Return an error indicator
    }
  }
    bool removePrompt(int id) {
    try {
      _box.remove(id);
      print("Prompt with ID $id removed successfully.");
      return true;
    } catch (e) {
      print("Error removing Prompt with ID $id: $e");
      return false;
    }
  }

  // Method to remove all Prompts
  void removeAllPrompts() {
    try {
      _box.removeAll();
      print("All prompts removed successfully.");
    } catch (e) {
      print("Error removing all prompts: $e");
    }
  }
}
