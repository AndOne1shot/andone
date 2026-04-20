import 'package:andone/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profilePageViewModelProvider = NotifierProvider<ProfilePageViewModel, void>(
  ProfilePageViewModel.new,
);

// 특정 연월의 completedHistory 조회
final completedHistoryProvider =
    StreamProvider.family<Map<String, int>, DateTime>((ref, month) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value({});

  final startStr =
      '${month.year}-${month.month.toString().padLeft(2, '0')}-01';
  final lastDay = DateTime(month.year, month.month + 1, 0).day;
  final endStr =
      '${month.year}-${month.month.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('completedHistory')
      .where(FieldPath.documentId, isGreaterThanOrEqualTo: startStr)
      .where(FieldPath.documentId, isLessThanOrEqualTo: endStr)
      .snapshots()
      .map((snapshot) => {
            for (final doc in snapshot.docs)
              doc.id: (doc.data()['count'] ?? 0) as int
          });
});

class ProfilePageViewModel extends Notifier<void> {
  final _auth = AuthService();

  @override
  void build() {}

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
