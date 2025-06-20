import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:jaibee1/data/models/category.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/core/theme/mint_jade_theme.dart'; // <-- Add your theme extension import

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  late Box<Category> _userCategoryBox;
  late Box<Category> _categoriesBox;

  String _selectedCategory = '';

  final Map<String, IconData> availableIcons = {
    'fastfood': Icons.fastfood,
    'commute': Icons.commute,
    'movie': Icons.movie,
    'shopping_cart': Icons.shopping_cart,
    'fitness_center': Icons.fitness_center,
    'savings': Icons.savings,
    'category': Icons.category,
    'coffee': Icons.coffee,
    'local_cafe': Icons.local_cafe,
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'directions_bike': Icons.directions_bike,
    'local_gas_station': Icons.local_gas_station,
    'flight': Icons.flight,
    'train': Icons.train,
    'local_hospital': Icons.local_hospital,
    'home': Icons.home,
    'phone': Icons.phone,
    'computer': Icons.computer,
    'movie_filter': Icons.movie_filter,
    'music_note': Icons.music_note,
    'sports_soccer': Icons.sports_soccer,
    'book': Icons.book,
    'local_library': Icons.local_library,
    'pets': Icons.pets,
    'local_florist': Icons.local_florist,
    'toys': Icons.toys,
    'school': Icons.school,
    'work': Icons.work,
    'local_offer': Icons.local_offer,
    'credit_card': Icons.credit_card,
    'account_balance': Icons.account_balance,
    'build': Icons.build,
    'local_mall': Icons.local_mall,
    'brush': Icons.brush,
    'cake': Icons.cake,
    'child_care': Icons.child_care,
    'directions_run': Icons.directions_run,
    'emoji_events': Icons.emoji_events,
    'event': Icons.event,
    'extension': Icons.extension,
    'golf_course': Icons.golf_course,
    'headphones': Icons.headphones,
    'healing': Icons.healing,
    'keyboard': Icons.keyboard,
    'local_pizza': Icons.local_pizza,
    'mic': Icons.mic,
    'nightlife': Icons.nightlife,
    'pool': Icons.pool,
    'restaurant_menu': Icons.restaurant_menu,
    'spa': Icons.spa,
    'star': Icons.star,
    'videogame_asset': Icons.videogame_asset,
    'watch': Icons.watch,
  };

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

  String _getLocalizedCategory(String name, S localizer) {
    switch (name.toLowerCase()) {
      case 'food':
        return localizer.food;
      case 'transport':
      case 'transportation':
        return localizer.transport;
      case 'entertainment':
        return localizer.entertainment;
      case 'coffee':
        return localizer.coffee;
      case 'income':
        return localizer.income;
      case 'shopping':
        return localizer.shopping;
      case 'health':
        return localizer.health;
      case 'bills':
        return localizer.bills;
      case 'groceries':
        return localizer.groceries;
      case 'beauty':
        return localizer.beauty;
      case 'electronics':
        return localizer.electronics;
      case 'books':
        return localizer.books;
      case 'pet care':
        return localizer.petCare;
      case 'gifts':
        return localizer.gifts;
      case 'home':
        return localizer.home;
      case 'savings':
        return localizer.savings;
      case 'events':
        return localizer.events;
      case 'fitness':
        return localizer.fitness;
      case 'other':
        return localizer.other;
      default:
        return name;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizer.categoryExists)));
      return;
    }

    _categoriesBox.add(Category(name: selected.name, icon: selected.icon));
    setState(() {
      _selectedCategory = '';
    });
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
                        Icon(availableIcons[cat.icon] ?? Icons.category),
                        const SizedBox(width: 10),
                        Text(_getLocalizedCategory(cat.name, localizer)),
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
                  border: const OutlineInputBorder(),
                ),
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
                    final iconData = availableIcons[cat.icon] ?? Icons.category;
                    final localizedName = _getLocalizedCategory(
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
