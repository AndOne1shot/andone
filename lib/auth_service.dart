import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<User?> signUp(String email, String password, String nickname) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'email': email,
        'nickname': nickname,
        'mood': 50,
        'maxMood': 100,
        'gold': 0,
        'totalCompleted': 0,
        'lastMoodDecreaseDate': null,
      });
      await _auth.signOut(); // 자동 로그인 방지
    }
    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
