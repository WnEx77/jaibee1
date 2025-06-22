import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'package:jaibee1/data/models/trancs.dart';
import 'package:jaibee1/data/models/category.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/core/theme/mint_jade_theme.dart';
import 'package:jaibee1/core/utils/category_utils.dart';
import 'package:another_flushbar/flushbar.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

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
    _customCategoryObjects = box.values.toList();
    if (_customCategoryObjects.isNotEmpty && !_isIncome) {
      _category = _customCategoryObjects.first.name;
    } else if (_isIncome) {
      _category = 'income';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;
    if (_isIncome && _category != 'income') _category = 'income';

    return Scaffold(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconAsset = isDark
        ? 'assets/images/Saudi_Riyal_Symbol_DarkMode.png'
        : 'assets/images/Saudi_Riyal_Symbol.png';

    return _styledContainer(
      child: TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        validator: (value) => (value == null || value.isEmpty)
            ? localizer.pleaseEnterAmount
            : null,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: localizer.amount,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(iconAsset, width: 24, height: 24),
          ),
          hintText: localizer.enterAmount,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(S localizer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = _isIncome
        ? [Category(name: 'income', icon: 'attach_money')]
        : _customCategoryObjects;

    return _styledContainer(
      child: DropdownButtonFormField<String>(
        value: _category.isNotEmpty ? _category : null,
        items: categories.map((cat) {
          return DropdownMenuItem<String>(
            value: cat.name,
            child: Row(
              children: [
                Icon(
                  getCategoryIcon(cat),
                  size: 22,
                  color: isDark ? Colors.tealAccent : Colors.teal,
                ),
                const SizedBox(width: 10),
                Text(
                  getLocalizedCategory(cat.name, localizer),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: _isIncome ? null : (val) => setState(() => _category = val!),
        decoration: InputDecoration(
          labelText: localizer.category,
          border: InputBorder.none,
        ),
        borderRadius: BorderRadius.circular(18),
        icon: Icon(Icons.keyboard_arrow_down_rounded, size: 28),
      ),
    );
  }

  Widget _buildTypeToggle(S localizer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTextColor = isDark ? Colors.black : Colors.white;
    final unselectedTextColor = isDark ? Colors.white : Colors.black;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[200],
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: ToggleButtons(
          isSelected: [_isIncome == false, _isIncome == true],
          onPressed: (int index) {
            setState(() {
              _isIncome = index == 1;
              _category = _isIncome
                  ? 'income'
                  : (_customCategoryObjects.isNotEmpty
                        ? _customCategoryObjects.first.name
                        : '');
            });
          },
          borderRadius: BorderRadius.circular(12),
          borderWidth: 1.5,
          selectedColor: selectedTextColor,
          fillColor: _isIncome ? Colors.green : Colors.red,
          color: unselectedTextColor,
          constraints: const BoxConstraints(minWidth: 120, minHeight: 45),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_downward),
                const SizedBox(width: 6),
                Text(
                  localizer.expense,
                  style: TextStyle(
                    color: !_isIncome ? selectedTextColor : unselectedTextColor,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_upward),
                const SizedBox(width: 6),
                Text(
                  localizer.income,
                  style: TextStyle(
                    color: _isIncome ? selectedTextColor : unselectedTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

  Widget _buildDescriptionField(S localizer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _styledContainer(
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 2,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: localizer.description,
          prefixIcon: Icon(
            Icons.notes_rounded,
            color: isDark ? Colors.tealAccent : Colors.teal,
          ),
          hintText: localizer.enterDescription,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(S localizer) {
    final mintTheme = Theme.of(context).extension<MintJadeColors>()!;
    return FilledButton.icon(
      onPressed: _submitForm,
      style: FilledButton.styleFrom(
        backgroundColor: mintTheme.buttonColor,
        foregroundColor: Colors.white, // Set text/icon color here
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: const Icon(Icons.add),
      label: Text(localizer.addTransaction),
    );
  }

  void _submitForm() {
    final localizer = S.of(context)!;

    if (_formKey.currentState!.validate()) {
      if (_category.isEmpty) {
        Flushbar(
          message: localizer.pleaseSelectCategory,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.error_outline, color: Colors.white),
        ).show(context);
        return;
      }

      final transaction = Transaction(
        category: _category,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        isIncome: _isIncome,
        date: _selectedDate,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
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

      Flushbar(
        message: localizer.transactionAdded,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      ).show(context);
    }
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
                  onDateTimeChanged: (newDate) => tempSelectedDate = newDate,
                ),
              ),
            ),
            CupertinoButton(
              child: const Text('Done'),
              onPressed: () {
                setState(() => _selectedDate = tempSelectedDate);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _styledContainer({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1.2,
        ),
      ),
      child: child,
    );
  }

  Widget _toggleButton(
    String label,
    bool isSelected,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green : Colors.grey.shade300,
          foregroundColor: isSelected ? Colors.white : Colors.black,
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
