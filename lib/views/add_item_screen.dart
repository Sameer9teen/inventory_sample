import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/inventory_provider.dart';

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.isEditing ? 'Edit Item' : 'Add Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ShadInput(
              placeholder: const Text('Name'),
              initialValue: provider.name,
              onChanged: (v) => provider.name = v,
            ),
            const SizedBox(height: 8),
            ShadInput(
              placeholder: const Text('Quantity'),
              initialValue: provider.quantity,
              keyboardType: TextInputType.number,
              onChanged: (v) => provider.quantity = v,
            ),
            const SizedBox(height: 8),
            ShadInput(
              placeholder: const Text('Description'),
              maxLines: 3,
              initialValue: provider.description,
              onChanged: (v) => provider.description = v,
            ),
            const SizedBox(height: 8),
            ShadInput(
              placeholder: const Text('Category (optional)'),
              initialValue: provider.category,
              onChanged: (v) => provider.category = v,
            ),
            const SizedBox(height: 16),
            ShadButton(
              onPressed: provider.isSaving
                  ? null
                  : () async {
                      try {
                        await provider.save();
                        if (context.mounted) Navigator.of(context).pop();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save item: $e')),
                          );
                        }
                      }
                    },
              child: provider.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(provider.isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}
