import 'package:flutter/material.dart';
import 'package:jaibee1/models/trancs.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/models/category.dart';
import 'package:jaibee1/widgets/app_background.dart'; // Import your background widget

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

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
      appBar: AppBar(
        title: Text(localizer.addTransaction),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 130, 148, 179),
        foregroundColor: Colors.white,
      ),
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
          border: InputBorder.none,
          icon: const Icon(Icons.attach_money),
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
        ? [Category(name: 'income', icon: '💰')]
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
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 130, 148, 179),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: _submitForm,
      icon: const Icon(Icons.add),
      label: Text(localizer.addTransaction),
    );
  }

  void _submitForm() {
    final localizer = S.of(context)!;

    if (_formKey.currentState!.validate()) {
      if (_category.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizer.pleaseSelectCategory)),
        );
        return;
      }

      final transaction = Transaction(
        category: _category,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        isIncome: _isIncome,
        date: _selectedDate,
      );

      Hive.box('transactions').add(transaction);

      setState(() {
        _amountController.clear();
        _isIncome = false;
        _selectedDate = DateTime.now();
        _category = _customCategoryObjects.isNotEmpty
            ? _customCategoryObjects.first.name
            : '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizer.transactionAdded)),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: Localizations.localeOf(context),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
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

  /// Map the category or its emoji icon string to a Flutter IconData.
  IconData _getCategoryIcon(Category category) {
    // Try to identify icon based on category name
    switch (category.name) {
      case 'food':
        return Icons.fastfood;
      case 'transportation':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'coffee':
        return Icons.coffee;
      case 'income':
        return Icons.attach_money;
      case 'other':
        return Icons.category;
    }

    // Fallback: map known emojis stored in category.icon to icons
    switch (category.icon) {
      case '🍔':
        return Icons.fastfood;
      case '🚗':
        return Icons.directions_car;
      case '🎬':
        return Icons.movie;
      case '☕':
        return Icons.coffee;
      case '💰':
        return Icons.attach_money;
      case '🔘':
        return Icons.category;
    }

    // Default fallback icon
    return Icons.label;
  }
}
