import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io' show File;

import '../providers/inventory_provider.dart';
import '../models/item.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? initialPath;
  const HomeScreen({super.key, this.initialPath});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _currentPath;
  String? _fileContent;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initialPath;

    if (_currentPath != null) {
      if (_currentPath!.startsWith('assets/')) {
        rootBundle.loadString(_currentPath!).then(
          (c) => setState(() => _fileContent = c),
        ).catchError(
          (e) => setState(() => _fileContent = 'Failed to load asset: $e'),
        );
      } else {
        try {
          File(_currentPath!).readAsString().then(
            (c) => setState(() => _fileContent = c),
          ).catchError(
            (e) => setState(() => _fileContent = 'Failed to load file: $e'),
          );
        } catch (e) {
          setState(() => _fileContent = 'Failed to load file: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final items = provider.filteredItems;
    final width = MediaQuery.of(context).size.width;
    final showRail = width >= 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: Row(
        children: [
          if (showRail)
            NavigationRail(
              selectedIndex: _selectedIndex,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2),
                  label: Text('Inventory'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add),
                  label: Text('Add'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
              onDestinationSelected: (index) async {
                if (index == 1) {
                  provider.startAdd();
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddItemScreen()),
                  );
                  setState(() => _selectedIndex = 0);
                  return;
                }
                setState(() => _selectedIndex = index);
              },
            ),
          Expanded(
            child: _selectedIndex == 2
                ? const Center(child: Text('Settings (placeholder)'))
                : Column(
                    children: [
                      if (_currentPath != null) ...[
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Card(
                            child: ListTile(
                              title: Text(_currentPath!),
                              subtitle: _fileContent != null
                                  ? const Text('Showing file content')
                                  : null,
                            ),
                          ),
                        ),
                        if (_fileContent != null)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              height: 240,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SingleChildScrollView(
                                    child: Text(_fileContent!),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                      Expanded(
                        child:
                            _buildInventoryContent(context, provider, items),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          provider.startAdd();
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddItemScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInventoryContent(
      BuildContext context, InventoryProvider provider, List<Item> items) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: ShadInput(
                  placeholder: const Text('Search items...'),
                  onChanged: (q) => provider.search = q,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 180,
                child: ShadSelect<String>(
                  options: [
                    const ShadOption(
                      value: '',
                      child: Text('All categories'),
                    ),
                    for (final cat in provider.categories)
                      ShadOption(value: cat, child: Text(cat)),
                  ],
                  selectedOptionBuilder: (context, value) =>
                      Text(value == null || value.isEmpty
                          ? 'All categories'
                          : value),
                  onChanged: (v) => provider.selectedCategory =
                      (v == null || v.isEmpty) ? null : v,
                  placeholder: const Text('Category'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('No items yet. Tap + to add one.'))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ShadCard(
                      title: Text(item.name),
                      description: Text('Quantity: ${item.quantity}'),
                      trailing: ShadButton.link(
                        child: const Icon(Icons.chevron_right),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  ItemDetailScreen(itemId: item.id)),
                        ),
                      ),
                      footer: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ShadButton.ghost(
                            child: const Icon(Icons.edit),
                            onPressed: () async {
                              provider.startEdit(item);
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const AddItemScreen()),
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
                                  content: Text(
                                      'Are you sure you want to delete "${item.name}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
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
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Failed to delete item: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
