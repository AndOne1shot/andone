import 'package:andone/model/item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 전체 아이템 목록
final itemListProvider = StreamProvider<List<ItemModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('items')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList());
});

final equipmentViewModelProvider = Provider((ref) => EquipmentViewModel());

class EquipmentViewModel {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // 아이템 구매
  // 반환값: null = 성공, String = 실패 메시지
  Future<String?> purchaseItem(ItemModel item, int currentGold, List<String> ownedItems) async {
    final uid = _uid;
    if (uid == null) return '로그인이 필요해요';
    if (ownedItems.contains(item.id)) return '이미 보유한 아이템이에요';
    if (currentGold < item.price) return '골드가 부족해요';

    await _db.collection('users').doc(uid).update({
      'gold': currentGold - item.price,
      'ownedItems': FieldValue.arrayUnion([item.id]),
    });

    return null;
  }

  // 아이템 장착
  Future<void> equipItem(ItemModel item) async {
    final uid = _uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).update({
      'equippedItems.${item.category}': item.id,
    });
  }

  // 아이템 해제
  Future<void> unequipItem(String category) async {
    final uid = _uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).update({
      'equippedItems.$category': FieldValue.delete(),
    });
  }
}
