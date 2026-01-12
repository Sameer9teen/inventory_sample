import 'package:flutter/foundation.dart';
import '../controllers/inventory_controller.dart';
import '../models/item.dart';

class InventoryProvider extends ChangeNotifier {    // holds app sate and updtates UI
  final InventoryController _controller;

  InventoryProvider(this._controller);

  List<Item> _items = [];      ///inventory list 
  String _search = '';
  String? _selectedCategory;

  List<Item> get items => _items;

  List<Item> get filteredItems {
    final lowerSearch = _search.toLowerCase();        
    return _items.where((item) {
      final matchesSearch =
          _search.isEmpty || item.name.toLowerCase().contains(lowerSearch);
      final matchesCategory =
          _selectedCategory == null ||
          _selectedCategory == '' ||
          item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  String get search => _search;
  set search(String q) {
    _search = q;
    notifyListeners();
  }

  String? get selectedCategory => _selectedCategory;
  set selectedCategory(String? c) {
    _selectedCategory = c;
    notifyListeners();
  }

  List<String> get categories {
    final set = <String>{};
    for (final it in _items) {
      if (it.category != null && it.category!.isNotEmpty) set.add(it.category!);
    }
    return set.toList()..sort();
  }

  Item? getItem(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> initialize() async {
    _items = await _controller.fetchItems();
    notifyListeners();
  }

  Item? _editingItem;
  bool _isSaving = false;

  bool get isEditing => _editingItem != null;
  bool get isSaving => _isSaving;

  String name = '';
  String quantity = '0';
  String description = '';
  String category = '';

  void startAdd() {
    _editingItem = null;
    name = '';
    quantity = '0';
    description = '';
    category = '';
    notifyListeners();
  }

  void startEdit(Item item) {
    _editingItem = item;
    name = item.name;
    quantity = item.quantity.toString();
    description = item.description ?? '';
    category = item.category ?? '';
    notifyListeners();
  }

  Future<void> save() async {                      /// method were the ,decides od the it 
    if (name.trim().isEmpty) throw Exception('Item name cannot be empty');   /// validation for fields
    final parsedQuantity = int.tryParse(quantity) ?? 0;
    _isSaving = true;
    notifyListeners();
    try {
      if (isEditing) {
        await updateItem(
          _editingItem!.id,
          name: name.trim(),
          quantity: parsedQuantity,
          description: description.trim(),
          category: category.isEmpty ? null : category.trim(),
        );
      } else {
        await addItem(
          name: name.trim(),
          quantity: parsedQuantity,
          description: description.trim(),
          category: category.isEmpty ? null : category.trim(),
        );
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> addItem({
    required String name,
    int quantity = 0, 
    String? description,
    String? category,
  }) async {
    await _controller.addItem(
      name: name,
      quantity: quantity,
      description: description,
      category: category,
    );
    await initialize();
  }

  Future<void> updateItem(
    String id, {
    String? name,
    int? quantity,
    String? description,
    String? category,
  }) async {
    await _controller.updateItem(
      id,
      name: name,
      quantity: quantity,
      description: description,
      category: category,
    );
    await initialize();
  }

  Future<void> removeItem(String id) async {
    await _controller.deleteItem(id);
    await initialize();
  }
}
