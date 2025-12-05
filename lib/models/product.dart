import 'package:firebase_database/firebase_database.dart';

class Product {
  final String id;
  final String name;
  final int price;            // rupiah, tanpa titik
  final String image;
  final String category;      // Food | Drink | Light Meal
  final String? tag;          // Sundanese Food | Squash | dst
  final bool active;
  final int createdAt;        // millis
  final int updatedAt;        // millis

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.tag,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'image': image,
        'category': category,
        'tag': tag,
        'active': active,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  static Product fromSnapshot(DataSnapshot snap) {
    final m = Map<String, dynamic>.from(snap.value as Map);
    return Product(
      id: snap.key ?? '',
      name: (m['name'] ?? '') as String,
      price: (m['price'] ?? 0) is int ? m['price'] as int : int.tryParse('${m['price']}') ?? 0,
      image: (m['image'] ?? '') as String,
      category: (m['category'] ?? '') as String,
      tag: (m['tag'] as String?),
      active: (m['active'] ?? true) as bool,
      createdAt: (m['createdAt'] ?? 0) as int,
      updatedAt: (m['updatedAt'] ?? 0) as int,
    );
  }
}
