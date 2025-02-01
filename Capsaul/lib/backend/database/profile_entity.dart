// 1. First, update the Profile model for ObjectBox
import 'dart:developer';

import 'package:objectbox/objectbox.dart';

@Entity()
class Profile {
  int id = 0;
  String emoji = '😊';

  @Property()
  List<String> categories = [];

  // Profile Insights
  String core = '';
  String lifestyle = '';

  @Property()
  List<String> hobbies = [];

  @Property()
  List<String> interests = [];

  @Property()
  List<String> habits = [];

  String work = '';

  @Property()
  List<String> skills = [];

  String learnings = '';
  String others = '';

  @Property()
  Map<String, dynamic>? conversationMetrics; // Add this field

  DateTime lastUpdated = DateTime.now();

  // Helper method to merge new insights
  void mergeInsights(Map<String, dynamic> newInsights) {
    try {
      core = _mergeText(core, newInsights['core']);
      lifestyle = _mergeText(lifestyle, newInsights['lifestyle']);
      hobbies = _mergeList(hobbies, newInsights['hobbies'] ?? []);
      interests = _mergeList(interests, newInsights['interests'] ?? []);
      habits = _mergeList(habits, newInsights['habits'] ?? []);
      work = _mergeText(work, newInsights['work']);
      skills = _mergeList(skills, newInsights['skills'] ?? []);
      learnings = _mergeText(learnings, newInsights['learnings']);
      others = _mergeText(others, newInsights['others']);
      
      // Merge conversation metrics
      if (newInsights['conversationMetrics'] != null) {
        conversationMetrics = Map<String, dynamic>.from(newInsights['conversationMetrics']);
      }
    } catch (e, stack) {
      log('Failed to merge insights: $e', stackTrace: stack);
    }
  }

  String _mergeText(String existing, dynamic newValue) {
    if (newValue is! String || newValue.isEmpty) return existing;
    return existing.isEmpty ? newValue : '$existing\n$newValue';
  }

  List<String> _mergeList(List<String> existing, dynamic newValues) {
    if (newValues is! List) return existing;
    return <String>{...existing, ...newValues.whereType<String>()}.toList();
  }
}
