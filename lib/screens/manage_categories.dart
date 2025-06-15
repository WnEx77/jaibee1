// screens/manage_categories_screen.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:jaibee1/models/category.dart';
import 'package:jaibee1/widgets/app_background.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final TextEditingController _controller = TextEditingController();
  late Box<Category> _categoryBox;

  @override
  void initState() {
    super.initState();
    _categoryBox = Hive.box<Category>('categories');
  }

  void _addCategory() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    if (name.toLowerCase() == 'income') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The "income" category already exists and cannot be modified.',
          ),
        ),
      );
      return;
    }

    final exists = _categoryBox.values.any((c) => c.name == name);
    if (exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Category already exists')));
      return;
    }

    _categoryBox.add(Category(name: name));
    _controller.clear();
    setState(() {});
  }

  void _deleteCategory(int index) {
    final category = _categoryBox.getAt(index);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category?.name}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _categoryBox.deleteAt(index);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoryBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'New Category',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.category),
                ),
                onSubmitted: (_) => _addCategory(),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _addCategory,
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, index) {
                    final cat = categories[index];
                    final isProtected = cat.name.toLowerCase() == 'income';

                    if (isProtected) {
                      return ListTile(
                        title: Text(cat.name),
                        trailing: const Icon(Icons.lock, color: Colors.grey),
                      );
                    }

                    return Dismissible(
                      key: Key(cat.name), // Ensure each key is unique
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Category'),
                            content: Text(
                              'Are you sure you want to delete "${cat.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        return confirmed ?? false;
                      },
                      onDismissed: (_) {
                        _categoryBox.deleteAt(index);
                        setState(() {});
                      },
                      child: ListTile(title: Text(cat.name)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
