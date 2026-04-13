import 'package:andone/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profilePageViewModelProvider = NotifierProvider<ProfilePageViewModel, void>(
  ProfilePageViewModel.new,
);

class ProfilePageViewModel extends Notifier<void> {
  final _auth = AuthService();

  @override
  void build() {}

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
