import 'package:andone/model/todo_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:andone/providers/user_provider.dart';

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

// 기능 Provider 및 ViewModel 클래스
final mainPageViewModelProvider = Provider((ref) => MainPageViewModel());

class MainPageViewModel {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 난이도별 골드 보상
  int _goldReward(int difficulty) {
    switch (difficulty) {
      case 1: return 10;
      case 2: return 15;
      case 3: return 20;
      case 4: return 30;
      case 5: return 50;
      default: return 20;
    }
  }

  // 난이도별 기분 증가량
  int _moodReward(int difficulty) {
    switch (difficulty) {
      case 1: return 5;
      case 2: return 8;
      case 3: return 10;
      case 4: return 15;
      case 5: return 20;
      default: return 10;
    }
  }

  Future<void> toggleTodo(
    String docId,
    bool currentStatus, {
    int difficulty = 3,
    int repeat = 0,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      if (repeat == 0) {
        // 일반 todo: isCompleted 토글
        final newStatus = !currentStatus;
        await _db
            .collection('users')
            .doc(uid)
            .collection('todos')
            .doc(docId)
            .update({'isCompleted': newStatus});

        if (newStatus) {
          await _handleTodoCompleted(uid, difficulty);
        }
      } else {
        // 반복 todo: lastCompletedDate를 오늘 날짜로 업데이트
        final today = DateTime.now();
        final todayStr =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        await _db
            .collection('users')
            .doc(uid)
            .collection('todos')
            .doc(docId)
            .update({'lastCompletedDate': todayStr});

        await _handleTodoCompleted(uid, difficulty);
      }
    } catch (e) {
      print("업데이트 실패: $e");
    }
  }

  Future<void> _handleTodoCompleted(String uid, int difficulty) async {
    final userDoc = await _db.collection('users').doc(uid).get();
    final userData = userDoc.data()!;

    final currentMood = (userData['mood'] ?? 50) as int;
    final maxMood = (userData['maxMood'] ?? 100) as int;
    final currentGold = (userData['gold'] ?? 0) as int;
    final totalCompleted = (userData['totalCompleted'] ?? 0) as int;

    final newMood = (currentMood + _moodReward(difficulty)).clamp(0, maxMood);
    final newGold = currentGold + _goldReward(difficulty);

    await _db.collection('users').doc(uid).update({
      'mood': newMood,
      'gold': newGold,
      'totalCompleted': totalCompleted + 1,
    });

    // 날짜별 완료 기록 저장
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final historyRef = _db
        .collection('users')
        .doc(uid)
        .collection('completedHistory')
        .doc(todayStr);
    final historyDoc = await historyRef.get();
    if (historyDoc.exists) {
      await historyRef.update({'count': (historyDoc.data()!['count'] ?? 0) + 1});
    } else {
      await historyRef.set({'count': 1});
    }

    print("기분: $currentMood → $newMood / 골드: $currentGold → $newGold");
  }
}
