import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:jaibee1/models/category.dart';
import 'package:jaibee1/l10n/s.dart'; // تأكد من استيراد ملف الترجمة

class CustomizeCategoriesScreen extends StatefulWidget {
   final S localizer;
    const CustomizeCategoriesScreen({Key? key, required this.localizer}) : super(key: key);

  @override
  _CustomizeCategoriesScreenState createState() =>
      _CustomizeCategoriesScreenState();
}

class _CustomizeCategoriesScreenState extends State<CustomizeCategoriesScreen> {
  final TextEditingController _newCategoryController = TextEditingController();
  late Box<String> customCategoriesBox;

  @override
  void initState() {
    super.initState();
    customCategoriesBox = Hive.box<String>('customCategories');
  }

  void _addCategory() {
    final newCat = _newCategoryController.text.trim();
    if (newCat.isNotEmpty && !customCategoriesBox.values.contains(newCat)) {
      customCategoriesBox.add(newCat);
      _newCategoryController.clear();
      setState(() {});
    }
  }

  void _removeCategory(int index) {
    customCategoriesBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localizer = widget.localizer;
    return Scaffold(
      appBar: AppBar(title: Text(localizer.customizeCategories)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _newCategoryController,
              decoration: InputDecoration(
                labelText: localizer.newCategory,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addCategory,
                ),
              ),
              onSubmitted: (_) => _addCategory(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: customCategoriesBox.length,
                itemBuilder: (context, index) {
                  final cat = customCategoriesBox.getAt(index)!;
                  return ListTile(
                    title: Text(cat),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeCategory(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
