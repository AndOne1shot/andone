import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String name;
  final String category; // "accessory" | "background"
  final int price;
  final String assetPath;
  final String thumbnailPath; // 목록용 썸네일 (없으면 assetPath 사용)
  final String description;

  ItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.assetPath,
    this.thumbnailPath = '',
    required this.description,
  });

  // 썸네일이 있으면 썸네일, 없으면 assetPath 반환
  String get displayPath => thumbnailPath.isNotEmpty ? thumbnailPath : assetPath;

  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: data['price'] ?? 0,
      assetPath: data['assetPath'] ?? '',
      thumbnailPath: data['thumbnailPath'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
