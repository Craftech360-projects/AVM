import 'package:lorem_ipsum/lorem_ipsum.dart';

class ChatUser {
  final String id;
  final String name;
  final String email;
  final String message;
  final int timestamp;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    required this.message,
    required this.timestamp,
  });

 
  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'message': message,
      'timestamp': timestamp,
    };
  }
}

List<Map<String, dynamic>> chatMessages = [
  {
    'id': '1',
    'name': 'Alice',
    'email': 'Alice@gmail.com',
    'message': 'Hello, everyone!',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '2',
    'name': 'Bob',
    'email': 'Bob@gmail.com',
    'message': 'Hey Alice, how are you?',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '3',
    'name': 'Charlie',
    'email': 'Charlie@gmail.com',
    'message': 'Hi all, what’s up?',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '4',
    'name': 'Diana',
    'email': 'Diana@gmail.com',
    'message': loremIpsum(words: 60),
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '1',
    'name': 'Alice',
    'email': 'Alice@gmail.com',
    'message': loremIpsum(words: 50),
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
   {
    'id': '3',
    'name': 'Charlie',
    'email': 'Charlie@gmail.com',
    'message': 'Hi all, what’s up?',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '4',
    'name': 'Diana',
    'email': 'Diana@gmail.com',
    'message': loremIpsum(words: 100),
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '1',
    'name': 'Alice',
    'email': 'Alice@gmail.com',
    'message': loremIpsum(words: 50),
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
];
