// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:objectbox/objectbox.dart';

@Entity()
class Prompt {
  @Id()
  int id = 0; 
  
  String prompt;
  String title;
  String overview;
  String actionItem;
  String category;
  String calender; 
  
  Prompt({
    required this.prompt,
    required this.title,
    required this.overview,
    required this.actionItem,
    required this.category,
    required this.calender,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'prompt': prompt,
      'title': title,
      'overview': overview,
      'actionItem': actionItem,
      'category': category,
      'calender': calender,
    };
  }

  factory Prompt.fromMap(Map<String, dynamic> map) {
    return Prompt(
      // id: map['id'] as int,
      prompt: map['prompt'] as String,
      title: map['title'] as String,
      overview: map['overview'] as String,
      actionItem: map['actionItem'] as String,
      category: map['category'] as String,
      calender: map['calender'] as String,
    );
  }

 

  @override
  String toString() {
    return 'Prompt(id: $id, prompt: $prompt, title: $title, overview: $overview, actionItem: $actionItem, category: $category, calender: $calender)';
  }
}
