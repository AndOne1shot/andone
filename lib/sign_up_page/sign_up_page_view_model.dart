import 'package:andone/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signUpPageViewModelProvider = NotifierProvider<SignUpPageViewModel, bool>(
  () {
    return SignUpPageViewModel();
  },
);

class SignUpPageViewModel extends Notifier<bool> {
  final _auth = AuthService();

  @override
  bool build() {
    return false; // 로딩 상태 초기값
  }

  Future<String?> signUp(String email, String password, String nickname) async {
    state = true;

    try {
      await _auth.signUp(email, password, nickname);
      return null; // 성공
    } catch (e) {
      return _handleError(e);
    } finally {
      state = false;
    }
  }

  String _handleError(dynamic e) {
    final error = e.toString();

    if (error.contains('email-already-in-use')) {
      return '이미 가입된 이메일입니다';
    } else if (error.contains('invalid-email')) {
      return '이메일 형식이 올바르지 않습니다';
    } else if (error.contains('weak-password')) {
      return '비밀번호는 6자 이상이어야 합니다';
    } else {
      return '회원가입 실패';
    }
  }
}
