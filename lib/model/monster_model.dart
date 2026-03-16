import 'package:cloud_firestore/cloud_firestore.dart';

class MonsterModel {
  final int monsterId;
  final String monsterName;
  final int atk;
  final int maxHp;
  final int hp;
  final int monsterLevel;
  final int rewardExp;

  MonsterModel({
    required this.monsterId,
    required this.monsterName,
    required this.atk,
    required this.maxHp,
    required this.hp,
    required this.monsterLevel,
    required this.rewardExp,
  });

  factory MonsterModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MonsterModel(
      monsterId: data['monsterId'] ?? 0,
      monsterName: data['monsterName'] ?? '',
      atk: data['atk'] ?? 0,
      maxHp: data['maxHp'] ?? 0,
      hp: data['hp'] ?? 0,
      monsterLevel: data['monsterLevel'] ?? 0,
      rewardExp: data['rewardExp'] ?? 0,
    );
  }
}
