import 'package:andone/model/monster_model.dart';
import 'package:andone/model/todo_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// todo-list 불러옴
final todoListProvider = StreamProvider<List<TodoModel>>((ref) {
  final now = DateTime.now();

  return FirebaseFirestore.instance
      .collection('todos')
      //.where('endTime', isGreaterThan: now)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => TodoModel.fromFirestore(doc)).toList(),
      );
});

// 몬스터 정보 불러옴
final monsterProvider = StreamProvider<List<MonsterModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('monsters')
      .where('monsterId', isEqualTo: 1)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => MonsterModel.fromFirestore(doc))
            .toList(),
      );
});

// 기능 Provider 및 ViewModel 클래스
final mainPageViewModelProvider = Provider((ref) => MainPageViewModel());

class MainPageViewModel {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> toggleTodo(String docId, bool currentStatus) async {
    try {
      await _db.collection('todos').doc(docId).update({
        'isCompleted': !currentStatus,
      });
    } catch (e) {
      print("업데이트 실패: $e");
    }
  }
}
