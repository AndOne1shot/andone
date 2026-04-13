import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  final String id;
  final String title;
  final String content;
  final int difficulty;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCompleted;
  final int repeat;
  final List<int> repeatDays; // 매주 반복 요일 (1=월 ~ 7=일)
  final String? lastCompletedDate; // 'yyyy-MM-dd' 형식

  TodoModel({
    required this.id,
    required this.title,
    required this.content,
    required this.difficulty,
    required this.startTime,
    required this.endTime,
    required this.isCompleted,
    required this.repeat,
    this.repeatDays = const [],
    this.lastCompletedDate,
  });

  factory TodoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TodoModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      difficulty: data['difficulty'] ?? 0,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      repeat: data['repeat'] ?? 0,
      repeatDays: List<int>.from(data['repeatDays'] ?? []),
      lastCompletedDate: data['lastCompletedDate'] as String?,
    );
  }
}
