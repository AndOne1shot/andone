import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  final String id;
  final String title;
  final String content;
  final int difficulty;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCompleted;

  TodoModel({
    required this.id,
    required this.title,
    required this.content,
    required this.difficulty,
    required this.startTime,
    required this.endTime,
    required this.isCompleted,
  });

  factory TodoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TodoModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      difficulty: data['difficulty'] ?? 0,
      // Firestore의 Timestamp를 Dart의 DateTime으로 변환
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      isCompleted: data['iscompleted'] ?? false,
    );
  }
}
