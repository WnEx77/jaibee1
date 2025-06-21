import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:jaibee1/data/models/category.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/core/theme/mint_jade_theme.dart'; // <-- Add your theme extension import
import 'package:jaibee1/core/utils/category_utils.dart'; // <-- Import your utility functions
import 'package:another_flushbar/flushbar.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  late Box<Category> _userCategoryBox;
  late Box<Category> _categoriesBox;

  String _selectedCategory = '';

  final List<Category> defaultUserCategories = [
    Category(name: 'shopping', icon: 'shopping_cart'),
    Category(name: 'health', icon: 'local_hospital'),
    Category(name: 'transport', icon: 'directions_car'),
    Category(name: 'food', icon: 'restaurant'),
    Category(name: 'education', icon: 'school'),
    Category(name: 'entertainment', icon: 'movie'),
    Category(name: 'fitness', icon: 'fitness_center'),
    Category(name: 'travel', icon: 'flight'),
    Category(name: 'home', icon: 'home'),
    Category(name: 'bills', icon: 'credit_card'),
    Category(name: 'groceries', icon: 'local_mall'),
    Category(name: 'beauty', icon: 'spa'),
    Category(name: 'electronics', icon: 'computer'),
    Category(name: 'books', icon: 'book'),
    Category(name: 'petCare', icon: 'pets'),
    Category(name: 'gifts', icon: 'cake'),
    // Category(name: 'savings', icon: 'savings'),
    Category(name: 'events', icon: 'event'),
  ];

  @override
  void initState() {
    super.initState();
    _userCategoryBox = Hive.box<Category>('userCategories');
    _categoriesBox = Hive.box<Category>('categories');
    _selectedCategory = '';

    if (_userCategoryBox.isEmpty) {
      for (final category in defaultUserCategories) {
        _userCategoryBox.add(category);
      }
    }
  }

  void _addCategory() {
    final localizer = S.of(context)!;

    if (_selectedCategory.isEmpty) return;

    final selected = defaultUserCategories.firstWhere(
      (c) => c.name == _selectedCategory,
    );

    final exists = _categoriesBox.values.any((c) => c.name == selected.name);
    if (exists) {
      Flushbar(
        message: localizer.categoryExists,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      ).show(context);
      return;
    }

    _categoriesBox.add(Category(name: selected.name, icon: selected.icon));
    setState(() {
      _selectedCategory = '';
    });

    Flushbar(
      message: localizer.categoryAdded,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;
    final mintTheme = Theme.of(context).extension<MintJadeColors>()!;

    final categories = _categoriesBox.values
        .where((c) => c.name != 'other')
        .toList();
    final userCategories = defaultUserCategories;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: mintTheme.appBarColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                localizer.manageCategories,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory.isEmpty ? null : _selectedCategory,
                items: userCategories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.name,
                    child: Row(
                      children: [
                        Icon(
                            getCategoryIcon(cat),
                          size: 22,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.tealAccent
                              : Colors.teal,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          getLocalizedCategory(cat.name, localizer),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: localizer.selectCategory,
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]!
                          : Colors.grey[200]!,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.teal, width: 1.5),
                  ),
                ),
                borderRadius: BorderRadius.circular(18),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mintTheme.buttonColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _addCategory,
                icon: const Icon(Icons.add),
                label: Text(localizer.addCategory),
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
                    final iconData = getCategoryIcon(cat);
                    final localizedName = getLocalizedCategory(
                      cat.name,
                      localizer,
                    );

                    return isProtected
                        ? ListTile(
                            leading: Icon(iconData),
                            title: Text(localizedName),
                            trailing: const Icon(
                              Icons.lock,
                              color: Colors.grey,
                            ),
                          )
                        : Dismissible(
                            key: Key(cat.name),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (_) async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(localizer.deleteCategory),
                                  content: Text(
                                    localizer.deleteCategoryConfirm(
                                      localizedName,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text(localizer.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(
                                        localizer.delete,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              return confirmed ?? false;
                            },
                            onDismissed: (_) {
                              _categoriesBox.deleteAt(index);
                              setState(() {});
                            },
                            child: ListTile(
                              leading: Icon(iconData),
                              title: Text(localizedName),
                            ),
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
