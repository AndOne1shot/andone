import 'package:andone/model/monster_model.dart';
import 'package:andone/model/todo_model.dart';
import 'package:andone/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 현재 로그인한 유저 정보 불러옴
final userProvider = StreamProvider<UserModel?>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
});

// todo-list 불러옴 (유저별)
final todoListProvider = StreamProvider<List<TodoModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('todos')
      .orderBy('startTime', descending: false)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => TodoModel.fromFirestore(doc)).toList(),
      );
});

// 몬스터 정보 불러옴 (유저별)
final monsterProvider = StreamProvider<List<MonsterModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('monsters')
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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('todos')
          .doc(docId)
          .update({'isCompleted': !currentStatus});
    } catch (e) {
      print("업데이트 실패: $e");
    }
  }
}
