import 'package:andone/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final todoDetailPageViewModelProvider = Provider((ref) => TodoDetailViewModel());

class TodoDetailViewModel {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 수정 기능 (startTime 추가)
  Future<void> updateTodo({
    required String docId,
    required String newTitle,
    required String newContent,
    required int difficulty,
    required DateTime startTime,
    required DateTime endTime,
    required int repeat,
    List<int> repeatDays = const [],
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('todos')
          .doc(docId)
          .update({
        'title': newTitle,
        'content': newContent,
        'difficulty': difficulty,
        'startTime': startTime,
        'endTime': endTime,
        'repeat': repeat,
        'repeatDays': repeatDays,
      });
      // 기존 알림 취소 후 새 시간으로 재예약
      await notificationService.cancelTodoReminder(docId);
      await notificationService.scheduleTodoReminder(
        docId: docId,
        title: newTitle,
        startTime: startTime,
        repeat: repeat,
        repeatDays: repeatDays,
      );
      print("업데이트 성공!");
    } catch (e) {
      print("업데이트 실패: $e");
    }
  }

  // 삭제 기능
  Future<void> deleteTodo(String docId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('todos')
          .doc(docId)
          .delete();

      // 예약된 알림 취소
      await notificationService.cancelTodoReminder(docId);
    } catch (e) {
      print("삭제 실패: $e");
    }
  }
}
