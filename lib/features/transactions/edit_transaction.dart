import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:jaibee1/data/models/trancs.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/data/models/category.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/shared/widgets/custom_app_bar.dart';
// import 'package:jaibee1/utils/category_utils.dart';
import 'package:jaibee1/core/theme/mint_jade_theme.dart';
import 'package:flutter/cupertino.dart';


class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;
  final int transactionKey;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.transactionKey,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  late bool _isIncome;
  late String _category;
  late DateTime _selectedDate;
  List<Category> _customCategories = [];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.transaction.description ?? '',
    );
    _isIncome = widget.transaction.isIncome;
    _category = widget.transaction.category;
    _selectedDate = widget.transaction.date;
    _loadCategories();
  }

  void _loadCategories() {
    final box = Hive.box<Category>('categories');
    setState(() {
      _customCategories = box.values.toList();
    });
  }

Future<void> _selectDate(BuildContext context) async {
  DateTime tempSelectedDate = _selectedDate;

  final isDark = Theme.of(context).brightness == Brightness.dark;

  await showCupertinoModalPopup<void>(
    context: context,
    builder: (_) => Container(
      height: 400,
      padding: const EdgeInsets.only(top: 16),
      color: isDark ? Colors.grey[900] : Colors.white,
      child: Column(
        children: [
          Expanded(
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: isDark ? Brightness.dark : Brightness.light,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 22,
                  ),
                ),
              ),
              child: CupertinoDatePicker(
                initialDateTime: tempSelectedDate,
                minimumDate: DateTime(2000),
                maximumDate: DateTime.now(),
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime newDate) {
                  tempSelectedDate = newDate;
                },
              ),
            ),
          ),
          CupertinoButton(
            child: const Text('Done'),
            onPressed: () {
              setState(() {
                _selectedDate = tempSelectedDate;
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    ),
  );
}

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final newTransaction = Transaction(
        amount: double.tryParse(_amountController.text) ?? 0.0,
        category: _category,
        isIncome: _isIncome,
        date: _selectedDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      Hive.box('transactions').put(widget.transactionKey, newTransaction);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)!.transactionUpdated)),
      );

      Navigator.of(context).pop();
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context)!.deleteTransaction),
        content: Text(S.of(context)!.areYouSureDeleteTransaction),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Hive.box('transactions').delete(widget.transactionKey);
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context)!.transactionDeleted)),
              );
            },
            child: Text(S.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildCategoryItems(S localizer) {
    if (_isIncome) {
      return [
        DropdownMenuItem(
          value: 'income',
          child: Row(
            children: [
              // Icon(availableIcons['savings'] ?? Icons.attach_money),
              const SizedBox(width: 10),
              Text(localizer.income),
            ],
          ),
        ),
      ];
    } else {
      return _customCategories.map((cat) {
        // final iconData = availableIcons[cat.icon] ?? Icons.category;
        final name = _getLocalizedCategory(cat.name, localizer);
        return DropdownMenuItem(
          value: cat.name,
          child: Row(
            children: [
              // Icon(iconData),
              const SizedBox(width: 10),
              Text(name),
            ],
          ),
        );
      }).toList();
    }
  }

  String _getLocalizedCategory(String key, S localizer) {
    switch (key) {
      case 'food':
        return localizer.food;
      case 'transportation':
        return localizer.transportation;
      case 'entertainment':
        return localizer.entertainment;
      case 'coffee':
        return localizer.coffee;
      case 'income':
        return localizer.income;
      case 'other':
        return localizer.other;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;
    final mintJade = Theme.of(context).extension<MintJadeColors>();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: CustomAppBar(
            title: localizer.editTransaction,
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: localizer.deleteTransaction,
                onPressed: _confirmDelete,
              ),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: localizer.amount,
                          border: const OutlineInputBorder(),
                          icon: Image.asset(
                            'assets/images/Saudi_Riyal_Symbol.png',
                            width: 24,
                            height: 24,
                            color: Colors.grey,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return localizer.pleaseEnterAmount;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _category.isNotEmpty ? _category : null,
                        decoration: InputDecoration(
                          labelText: localizer.category,
                          border: const OutlineInputBorder(),
                          icon: Icon(_getIconForCategory(_category)),
                        ),
                        onChanged: _isIncome
                            ? null
                            : (val) => setState(() => _category = val!),
                        items: _buildCategoryItems(localizer),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizer.pleaseSelectCategory;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // tileColor: Colors.blue.shade50.withOpacity(0.3),
                        leading: Icon(
                          Icons.calendar_today,
                          color: mintJade!.buttonColor,
                        ),
                        title: Text(
                          '${localizer.date}: ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_selectedDate)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: localizer.description,
                          border: const OutlineInputBorder(),
                          icon: const Icon(Icons.notes),
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: Text(localizer.saveChanges),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mintJade.buttonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _saveTransaction,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String key) {
    switch (key.toLowerCase()) {
      case 'shopping':
        return Icons.shopping_cart;
      case 'health':
        return Icons.local_hospital;
      case 'transport':
        return Icons.directions_car;
      case 'food':
        return Icons.restaurant;
      case 'education':
        return Icons.school;
      case 'entertainment':
        return Icons.movie;
      case 'fitness':
        return Icons.fitness_center;
      case 'travel':
        return Icons.flight;
      case 'home':
        return Icons.home;
      case 'bills':
        return Icons.credit_card;
      case 'groceries':
        return Icons.local_mall;
      case 'beauty':
        return Icons.spa;
      case 'electronics':
        return Icons.computer;
      case 'books':
        return Icons.book;
      case 'petcare': // note lowercase
        return Icons.pets;
      case 'gifts':
        return Icons.cake;
      case 'savings':
        return Icons.savings;
      case 'events':
        return Icons.event;
      case 'income':
        return Icons.monetization_on;
      case 'coffee':
        return Icons.coffee;
      case 'transportation':
        return Icons.directions_bus;
      case 'other':
        return Icons.category;
      default:
        return Icons.category;
    }
  }
}
