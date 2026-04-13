import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final todoCreateViewModelProvider = Provider(
  (ref) => TodoCreatePageViewModel(),
);

class TodoCreatePageViewModel {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createTodo({
    required String title,
    required String content,
    required int difficulty,
    required DateTime startTime,
    required DateTime endTime,
    required int repeat,
    List<int> repeatDays = const [],
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await _db.collection('users').doc(uid).collection('todos').add({
        'title': title,
        'content': content,
        'difficulty': difficulty,
        'startTime': startTime,
        'endTime': endTime,
        'isCompleted': false,
        'repeat': repeat,
        'repeatDays': repeatDays,
        'lastCompletedDate': null,
      });
    } catch (e) {
      print("Todo 생성 실패: $e");
    }
  }
}
