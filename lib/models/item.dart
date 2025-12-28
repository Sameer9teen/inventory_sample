import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String name;
  final int quantity;
  final String? description;
  final String? category;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    this.description,
    this.category,
  });

  factory Item.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      description: data['description'],
      category: data['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'description': description,
      'category': category,
    };
  }
}
