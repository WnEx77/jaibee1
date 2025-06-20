import 'package:flutter/material.dart';
import 'package:jaibee1/data/models/trancs.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/data/models/category.dart';
import 'package:jaibee1/shared/widgets/app_background.dart'; // Import your background widget
import 'package:jaibee1/core/theme/mint_jade_theme.dart';
// import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/cupertino.dart';


class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();// 👈 NEW
  

  String _category = '';
  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();

  List<Category> _customCategoryObjects = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    final box = Hive.box<Category>('categories');
    setState(() {
      _customCategoryObjects = box.values.toList();

      if (_customCategoryObjects.isNotEmpty && !_isIncome) {
        _category = _customCategoryObjects.first.name;
      } else if (_isIncome) {
        _category = 'income';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;

    if (_isIncome && _category != 'income') {
      _category = 'income';
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(localizer.addTransaction),
      //   centerTitle: true,
      //   // backgroundColor: Colors.transparent,
      //   // foregroundColor: Colors.white,
      // ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildAmountField(localizer),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(localizer),
                  const SizedBox(height: 16),
                  _buildTypeToggle(localizer),
                  const SizedBox(height: 16),
                  _buildDatePicker(localizer),
                  const SizedBox(height: 16),
                  _buildDescriptionField(localizer),
                  const SizedBox(height: 24),
                  _buildSubmitButton(localizer),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField(S localizer) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _amountController,
        decoration: InputDecoration(
          labelText: localizer.amount,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.attach_money, color: Colors.blueGrey),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return localizer.pleaseEnterAmount;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryDropdown(S localizer) {
    final categories = _isIncome
        ? [Category(name: 'income', icon: 'attach_money')] // FIXED
        : _customCategoryObjects;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8),
      child: DropdownButtonFormField<String>(
        value: _category.isNotEmpty ? _category : null,
        decoration: InputDecoration(
          labelText: localizer.category,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: _isIncome
            ? null
            : (String? newValue) {
                setState(() {
                  _category = newValue!;
                });
              },
        items: categories.map((categoryObj) {
          return DropdownMenuItem<String>(
            value: categoryObj.name,
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(categoryObj),
                  size: 24,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 8),
                Text(_getLocalizedCategory(categoryObj.name, localizer)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypeToggle(S localizer) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: !_isIncome ? Colors.red : Colors.grey.shade300,
              foregroundColor: !_isIncome ? Colors.white : Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isIncome = false;
                _category = _customCategoryObjects.isNotEmpty
                    ? _customCategoryObjects.first.name
                    : '';
              });
            },
            icon: const Icon(Icons.arrow_downward),
            label: Text(localizer.expense),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isIncome ? Colors.green : Colors.grey.shade300,
              foregroundColor: _isIncome ? Colors.white : Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isIncome = true;
                _category = 'income';
              });
            },
            icon: const Icon(Icons.arrow_upward),
            label: Text(localizer.income),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(S localizer) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        '${localizer.date}: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildSubmitButton(S localizer) {
    final mintTheme = Theme.of(context).extension<MintJadeColors>()!;
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: mintTheme.buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: _submitForm,
      icon: const Icon(Icons.add),
      label: Text(localizer.addTransaction),
    );
  }

  Widget _buildDescriptionField(S localizer) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: localizer.description,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.notes, color: Colors.blueGrey),
        ),
      ),
    );
  }

  void _submitForm() {
    final localizer = S.of(context)!;

    if (_formKey.currentState!.validate()) {
      if (_category.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizer.pleaseSelectCategory)));
        return;
      }

      final transaction = Transaction(
        category: _category,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        isIncome: _isIncome,
        date: _selectedDate,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null, // 👈 New field added
      );

      Hive.box('transactions').add(transaction);

      setState(() {
        _amountController.clear();
         _descriptionController.clear();
        _isIncome = false;
        _selectedDate = DateTime.now();
        _category = _customCategoryObjects.isNotEmpty
            ? _customCategoryObjects.first.name
            : '';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizer.transactionAdded)));
    }
  }

Future<void> _selectDate(BuildContext context) async {
  DateTime tempSelectedDate = _selectedDate;

  await showCupertinoModalPopup<void>(
    context: context,
    builder: (_) => Container(
      height: 400,
      padding: const EdgeInsets.only(top: 16),
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
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
      default:
        return name;
    }
  }

  /// Map the category or its emoji icon string to a Flutter IconData.
  IconData _getCategoryIcon(Category category) {
    switch (category.icon) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'directions_car':
        return Icons.directions_car;
      case 'restaurant':
        return Icons.restaurant;
      case 'school':
        return Icons.school;
      case 'movie':
        return Icons.movie;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'flight':
        return Icons.flight;
      case 'home':
        return Icons.home;
      case 'credit_card':
        return Icons.credit_card;
      case 'local_mall':
        return Icons.local_mall;
      case 'spa':
        return Icons.spa;
      case 'computer':
        return Icons.computer;
      case 'book':
        return Icons.book;
      case 'pets':
        return Icons.pets;
      case 'cake':
        return Icons.cake;
      case 'savings':
        return Icons.savings;
      case 'event':
        return Icons.event;
      case 'attach_money':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }
}
