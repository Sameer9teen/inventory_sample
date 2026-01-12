import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class InventoryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('inventory');

  Future<List<Item>> fetchItems() async {
    final snapshot = await _collection.get();    ///this were the collection from the firestore selected were from 
    return snapshot.docs.map(Item.fromFirestore).toList();  /// from the firestore selected category document from firestore raw format data to the model structure format maps it 
  }

  Future<void> addItem({
    required String name,
    int quantity = 0,
    String? description,
    String? category,
  }) async {
    await _collection.add({
      'name': name,
      'quantity': quantity,
      'description': description,
      'category': category,
    });
  }

  Future<void> updateItem(
    String id, {
    String? name,
    int? quantity,
    String? description,
    String? category,
  }) async {
    await _collection.doc(id).update({
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
    });
  }

  Future<void> deleteItem(String id) async {
    await _collection.doc(id).delete();
  }
}
