// 1. First, update the Profile model for ObjectBox
import 'dart:convert';
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
  String? conversationMetricsJson;

  Map<String, dynamic> get conversationMetrics {
    if (conversationMetricsJson == null || conversationMetricsJson!.isEmpty) {
      log("⚠️ No stored conversation metrics found.");
      return {};
    }
    try {
      return jsonDecode(conversationMetricsJson!);
    } catch (e) {
      log("❌ Error decoding conversation metrics: $e");
      return {};
    }
  }

  set conversationMetrics(Map<String, dynamic> value) {
    conversationMetricsJson = jsonEncode(value);
  }

  DateTime lastUpdated = DateTime.now();

  // Helper method to merge new insights
  void mergeInsights(Map<String, dynamic> newInsights) {
    try {
      core = _mergeText(core, newInsights['core']);
      lifestyle = _mergeText(lifestyle, newInsights['lifestyle']);
      hobbies = _mergeList(hobbies, _ensureList(newInsights['hobbies']));
      interests = _mergeList(interests, _ensureList(newInsights['interests']));
      habits = _mergeList(habits, _ensureList(newInsights['habits']));
      work = _mergeText(work, newInsights['work']);
      skills = _mergeList(skills, _ensureList(newInsights['skills']));
      learnings = _mergeText(learnings, newInsights['learnings']);
      others = _mergeText(others, newInsights['others']);

      // Merge conversation metrics
      if (newInsights['conversationMetrics'] != null) {
        conversationMetrics =
            Map<String, dynamic>.from(newInsights['conversationMetrics']);
      }
    } catch (e, stack) {
      log('Failed to merge insights: $e', stackTrace: stack);
    }
  }

  List<String> _ensureList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    } else if (value is String) {
      return [value];
    }
    return [];
  }

  String _mergeText(String existing, dynamic newValue) {
    if (newValue is! String || newValue.isEmpty) return existing;
    return existing.isEmpty ? newValue : '$existing\n$newValue';
  }

  List<String> _mergeList(List<String> existing, List<String> newValues) {
    return <String>{...existing, ...newValues}.toList();
  }
}
