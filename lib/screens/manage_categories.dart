import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:jaibee1/models/category.dart';
import 'package:jaibee1/widgets/app_background.dart';
import 'package:jaibee1/l10n/s.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final TextEditingController _controller = TextEditingController();
  late Box<Category> _categoryBox;

  String _selectedIcon = 'category';
  // bool _showIconPicker = false; // <-- new flag

  final Map<String, IconData> availableIcons = {
    'fastfood': Icons.fastfood,
    'commute': Icons.commute,
    'movie': Icons.movie,
    'shopping_cart': Icons.shopping_cart,
    'fitness_center': Icons.fitness_center,
    'savings': Icons.savings,
    'category': Icons.category, // default
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

  @override
  void initState() {
    super.initState();
    _categoryBox = Hive.box<Category>('categories');
  }

  void _addCategory() {
    final name = _controller.text.trim();
    final localizer = S.of(context)!;

    if (name.isEmpty) return;

    if (name.toLowerCase() == 'income') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizer.incomeProtected)));
      return;
    }

    final exists = _categoryBox.values.any((c) => c.name == name);
    if (exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizer.categoryExists)));
      return;
    }

    _categoryBox.add(Category(name: name, icon: _selectedIcon));
    _controller.clear();
    setState(() {
      _selectedIcon = 'category';
    });
  }

void _showIconPickerM() {
  showModalBottomSheet(
    context: context,
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: availableIcons.entries.map((entry) {
            final isSelected = _selectedIcon == entry.key;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedIcon = entry.key);
                Navigator.pop(context); // close the modal
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.blue : Colors.grey.shade200,
                  border: Border.all(
                    color: isSelected ? Colors.blueAccent : Colors.grey,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  entry.value,
                  color: isSelected ? Colors.white : Colors.black,
                  size: 28,
                ),
              ),
            );
          }).toList(),
        ),
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;
    final categories = _categoryBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: Text(localizer.manageCategories)),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: localizer.newCategory,
                  border: const OutlineInputBorder(),
                  suffixIcon: GestureDetector(
                    onTap: _showIconPickerM,
                    child: Icon(
                      availableIcons[_selectedIcon] ?? Icons.category,
                    ),
                  ),
                ),
                onSubmitted: (_) => _addCategory(),
              ),

              const SizedBox(height: 12),

              // NEW BUTTON TO TOGGLE ICON PICKER VISIBILITY
              // ElevatedButton.icon(
              //   onPressed: () {
              //     setState(() {
              //       _showIconPicker = !_showIconPicker;
              //     });
              //   },
              //   icon: const Icon(Icons.color_lens),
              //   label: Text(localizer.selectIcon),
              // ),

              // const SizedBox(height: 12),

              // // ICON PICKER VISIBLE ONLY WHEN _showIconPicker IS TRUE
              // if (_showIconPicker)
              //   Wrap(
              //     spacing: 10,
              //     runSpacing: 10,
              //     children: availableIcons.entries.map((entry) {
              //       final isSelected = _selectedIcon == entry.key;
              //       return GestureDetector(
              //         onTap: () {
              //           setState(() {
              //             _selectedIcon = entry.key;
              //             _showIconPicker = false; // hide picker after select
              //           });
              //         },
              //         child: Container(
              //           decoration: BoxDecoration(
              //             shape: BoxShape.circle,
              //             color: isSelected
              //                 ? Colors.blue
              //                 : Colors.grey.shade200,
              //             border: Border.all(
              //               color: isSelected ? Colors.blueAccent : Colors.grey,
              //               width: 2,
              //             ),
              //           ),
              //           padding: const EdgeInsets.all(10),
              //           child: Icon(
              //             entry.value,
              //             color: isSelected ? Colors.white : Colors.black,
              //           ),
              //         ),
              //       );
              //     }).toList(),
              //   ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
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

                    if (isProtected) {
                      return ListTile(
                        leading: Icon(iconData),
                        title: Text(cat.name),
                        trailing: const Icon(Icons.lock, color: Colors.grey),
                      );
                    }

                    return Dismissible(
                      key: Key(cat.name),
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
                            title: Text(localizer.deleteCategory),
                            content: Text(
                              localizer.deleteCategoryConfirm(cat.name),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(localizer.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(
                                  localizer.delete,
                                  style: const TextStyle(color: Colors.red),
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
                      child: ListTile(
                        leading: Icon(iconData),
                        title: Text(cat.name),
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
