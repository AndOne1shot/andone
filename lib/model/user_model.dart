import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nickname;
  final int mood;
  final int maxMood;
  final int gold;
  final int totalCompleted;
  final String? lastMoodDecreaseDate;

  UserModel({
    required this.uid,
    required this.email,
    required this.nickname,
    required this.mood,
    required this.maxMood,
    required this.gold,
    required this.totalCompleted,
    this.lastMoodDecreaseDate,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nickname: data['nickname'] ?? '',
      mood: data['mood'] ?? 50,
      maxMood: data['maxMood'] ?? 100,
      gold: data['gold'] ?? 0,
      totalCompleted: data['totalCompleted'] ?? 0,
      lastMoodDecreaseDate: data['lastMoodDecreaseDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nickname': nickname,
      'mood': mood,
      'maxMood': maxMood,
      'gold': gold,
      'totalCompleted': totalCompleted,
      'lastMoodDecreaseDate': lastMoodDecreaseDate,
    };
  }

  // UserModel copyWith({
  //   String? nickname,
  //   int? mood,
  //   int? maxMood,
  //   int? gold,
  //   int? totalCompleted,
  //   String? lastMoodDecreaseDate,
  // }) {
  //   return UserModel(
  //     uid: uid,
  //     email: email,
  //     nickname: nickname ?? this.nickname,
  //     mood: mood ?? this.mood,
  //     maxMood: maxMood ?? this.maxMood,
  //     gold: gold ?? this.gold,
  //     totalCompleted: totalCompleted ?? this.totalCompleted,
  //     lastMoodDecreaseDate: lastMoodDecreaseDate ?? this.lastMoodDecreaseDate,
  //   );
  // }
}
