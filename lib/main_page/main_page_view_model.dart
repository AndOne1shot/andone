import 'package:andone/model/monster_model.dart';
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

  // 난이도 배율 (B안)
  double _difficultyMultiplier(int difficulty) {
    switch (difficulty) {
      case 1:
        return 0.5;
      case 2:
        return 0.8;
      case 3:
        return 1.0;
      case 4:
        return 1.5;
      case 5:
        return 2.0;
      default:
        return 1.0;
    }
  }

  Future<void> toggleTodo(
    String docId,
    bool currentStatus, {
    int difficulty = 3,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // 1. todo isCompleted 토글
      final newStatus = !currentStatus;
      await _db
          .collection('users')
          .doc(uid)
          .collection('todos')
          .doc(docId)
          .update({'isCompleted': newStatus});

      // 2. 완료로 바뀔 때만 몬스터 데미지 처리
      if (newStatus) {
        await _dealDamageToMonster(uid, difficulty);
      }
    } catch (e) {
      print("업데이트 실패: $e");
    }
  }

  Future<void> _dealDamageToMonster(String uid, int difficulty) async {
    // 유저 정보 조회
    final userDoc = await _db.collection('users').doc(uid).get();
    final userData = userDoc.data()!;
    final atk = (userData['atk'] ?? 10) as int;

    // 데미지 계산
    final damage = (atk * _difficultyMultiplier(difficulty)).round();

    // 현재 몬스터 조회
    final monsterSnapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('monsters')
        .limit(1)
        .get();

    if (monsterSnapshot.docs.isEmpty) return;

    final monsterDoc = monsterSnapshot.docs.first;
    final monsterData = monsterDoc.data();
    final currentHp = (monsterData['hp'] ?? 0) as int;
    final newHp = (currentHp - damage).clamp(0, 99999);

    if (newHp <= 0) {
      // 몬스터 처치!
      final rewardExp = (monsterData['rewardExp'] ?? 30) as int;
      final maxHp = (monsterData['maxHp'] ?? 100) as int;
      final monsterId = (monsterData['monsterId'] ?? 1) as int;
      await monsterDoc.reference.update({'hp': 0});
      await _handleMonsterDefeated(
        uid,
        userData,
        rewardExp,
        maxHp,
        monsterId,
        monsterDoc.reference,
      );
    } else {
      await monsterDoc.reference.update({'hp': newHp});
      print("데미지: $damage, 몬스터 HP: $currentHp → $newHp");
    }
  }

  Future<void> _handleMonsterDefeated(
    String uid,
    Map<String, dynamic> userData,
    int rewardExp,
    int monsterMaxHp,
    int currentMonsterId,
    DocumentReference monsterRef,
  ) async {
    print("몬스터 처치! 경험치 +$rewardExp");

    int currentExp = (userData['exp'] ?? 0) as int;
    int currentLevel = (userData['level'] ?? 1) as int;
    int maxExp = (userData['maxExp'] ?? 100) as int;
    int currentHp = (userData['hp'] ?? 100) as int;
    int maxHp = (userData['maxHp'] ?? 100) as int;
    int atk = (userData['atk'] ?? 10) as int;

    int newExp = currentExp + rewardExp;

    // 레벨업 체크
    if (newExp >= maxExp) {
      newExp = newExp - maxExp;
      currentLevel += 1;
      maxExp = (maxExp * 1.5).round(); // 다음 레벨 필요 경험치 1.5배
      maxHp += 20; // 최대 HP 증가
      currentHp = maxHp; // HP 풀 회복
      atk += 3; // 공격력 증가
      print("레벨업! Lv.$currentLevel / ATK: $atk / MaxHP: $maxHp");
    }

    // 유저 스탯 업데이트
    await _db.collection('users').doc(uid).update({
      'exp': newExp,
      'level': currentLevel,
      'maxExp': maxExp,
      'hp': currentHp,
      'maxHp': maxHp,
      'atk': atk,
    });

    // 다음 몬스터로 교체
    final nextMonsterId = currentMonsterId + 1;
    final nextMaxHp = (monsterMaxHp * 1.2).round(); // 다음 몬스터는 HP 1.2배

    await monsterRef.update({
      'monsterId': nextMonsterId,
      'monsterName': '몬스터 $nextMonsterId',
      'hp': nextMaxHp,
      'maxHp': nextMaxHp,
      'atk': (userData['atk'] as int? ?? 10) + 2,
      'monsterLevel': currentLevel,
      'rewardExp': (rewardExp * 1.3).round(), // 경험치도 1.3배
    });
    print("다음 몬스터 등장! ID: $nextMonsterId / HP: $nextMaxHp");
  }
}
