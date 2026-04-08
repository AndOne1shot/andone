import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nickname;
  final int level;
  final int exp;
  final int maxExp;
  final int hp;
  final int maxHp;
  final int atk;

  UserModel({
    required this.uid,
    required this.email,
    required this.nickname,
    required this.level,
    required this.exp,
    required this.maxExp,
    required this.hp,
    required this.maxHp,
    required this.atk,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nickname: data['nickname'] ?? '',
      level: data['level'] ?? 1,
      exp: data['exp'] ?? 0,
      maxExp: data['maxExp'] ?? 100,
      hp: data['hp'] ?? 100,
      maxHp: data['maxHp'] ?? 100,
      atk: data['atk'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nickname': nickname,
      'level': level,
      'exp': exp,
      'maxExp': maxExp,
      'hp': hp,
      'maxHp': maxHp,
      'atk': atk,
    };
  }

  // 레벨업 여부 확인
  bool get canLevelUp => exp >= maxExp;

  UserModel copyWith({
    String? nickname,
    int? level,
    int? exp,
    int? maxExp,
    int? hp,
    int? maxHp,
    int? atk,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      nickname: nickname ?? this.nickname,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      maxExp: maxExp ?? this.maxExp,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      atk: atk ?? this.atk,
    );
  }
}
