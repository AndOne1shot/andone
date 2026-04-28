import 'package:andone/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final todoCreatePageViewModelProvider = Provider(
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
      final docRef = await _db.collection('users').doc(uid).collection('todos').add({
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

      // 30분 전 알림 예약
      await notificationService.scheduleTodoReminder(
        docId: docRef.id,
        title: title,
        startTime: startTime,
        repeat: repeat,
        repeatDays: repeatDays,
      );
    } catch (e) {
      print("Todo 생성 실패: $e");
    }
  }
}
