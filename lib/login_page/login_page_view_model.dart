import 'package:andone/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginPageViewModelProvider = NotifierProvider<LoginPageViewModel, bool>(
  () {
    return LoginPageViewModel();
  },
);

class LoginPageViewModel extends Notifier<bool> {
  final _auth = AuthService();

  @override
  bool build() {
    return false; // 초기 상태
  }

  // 🔥 로그인 (Firebase 기준)
  Future<String?> signIn(String email, String password) async {
    state = true;

    try {
      await _auth.signIn(email, password);
      return null; // 성공
    } catch (e) {
      return _handleError(e);
    } finally {
      state = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 🔥 Firebase 에러 → 사용자 메시지
  String _handleError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-credential':
        case 'invalid-login-credentials':
          return '이메일 또는 비밀번호가 올바르지 않습니다';

        default:
          return '로그인 실패 (${e.code})';
      }
    }

    return '로그인 실패';
  }
}
