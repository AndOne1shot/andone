import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final todoDetailViewModelProvider = Provider((ref) => TodoDetailViewModel());

class TodoDetailViewModel {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 수정 기능 (startTime 추가)
  Future<void> updateTodo({
    required String docId,
    required String newTitle,
    required String newContent,
    required int difficulty,
    required DateTime startTime,
    required DateTime endTime, // 이제 이 값을 그대로 넣습니다.
    // required DateTime endTime
  }) async {
    try {
      await _db.collection('todos').doc(docId).update({
        'title': newTitle,
        'content': newContent,
        'difficulty': difficulty,
        'startTime': startTime, // Firestore가 알아서 Timestamp로 변환합니다.
        'endTime': endTime,
        // 'endTime': endTime,
      });
      print("업데이트 성공!");
    } catch (e) {
      print("업데이트 실패: $e");
    }
  }

  // 삭제 기능
  Future<void> deleteTodo(String docId) async {
    try {
      await _db.collection('todos').doc(docId).delete();
    } catch (e) {
      print("삭제 실패: $e");
    }
  }
}
