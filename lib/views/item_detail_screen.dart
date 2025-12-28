import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/inventory_provider.dart';
import '../models/item.dart';
import 'add_item_screen.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final item = provider.getItem(itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item not found')),
        body: const Center(child: Text('Item not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          ShadButton.ghost(
            child: const Icon(Icons.edit),
            onPressed: () {
              provider.startEdit(item);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddItemScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
          ShadButton.destructive(
            child: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: Text('Are you sure you want to delete "${item.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await provider.removeItem(item.id);
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete item: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadCard(title: Text(item.name)),
            const SizedBox(height: 8),
            ShadCard(description: Text('Quantity: ${item.quantity}')),
            const SizedBox(height: 8),
            if (item.description != null && item.description!.isNotEmpty)
              ShadCard(
                title: const Text('Description'),
                child: Text(item.description!),
              ),
            const SizedBox(height: 8),
            if (item.category != null && item.category!.isNotEmpty)
              ShadCard(
                title: const Text('Category'),
                child: Text(item.category!),
              ),
          ],
        ),
      ),
    );
  }
}
