import 'package:flutter/material.dart';
import 'package:jaibee1/models/trancs.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/models/category.dart';
import 'package:jaibee1/widgets/app_background.dart';
import 'package:jaibee1/widgets/custom_app_bar.dart';
import 'package:jaibee1/utils/category_utils.dart';
import 'package:jaibee1/providers/mint_jade_theme.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;
  final int transactionKey;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.transactionKey,
  });

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController; // 👈 NEW
  late String _category;
  late bool _isIncome;
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
    ); // 👈 NEW
    _category = widget.transaction.category;
    _isIncome = widget.transaction.isIncome;
    _selectedDate = widget.transaction.date;
    _loadCategories();
  }

  void _loadCategories() {
    final box = Hive.box<Category>('categories');
    setState(() {
      _customCategories = box.values.toList();
    });
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    TextFormField(
                      controller: _amountController,
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
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
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
                        icon: const Icon(Icons.category),
                      ),
                      onChanged: _isIncome
                          ? null
                          : (String? newValue) {
                              setState(() {
                                _category = newValue!;
                              });
                            },
                      items: (_isIncome
                          ? [
                              DropdownMenuItem<String>(
                                value: 'income',
                                child: Row(
                                  children: [
                                    Icon(availableIcons['savings'] ?? Icons.attach_money),
                                    const SizedBox(width: 10),
                                    Text(localizer.income),
                                  ],
                                ),
                              ),
                            ]
                          : _customCategories.map((category) {
                              final iconData = availableIcons[category.icon] ?? Icons.category;
                              final localizedName = _getLocalizedCategory(
                                category.name,
                                localizer,
                              );
                              return DropdownMenuItem<String>(
                                value: category.name,
                                child: Row(
                                  children: [
                                    Icon(iconData),
                                    const SizedBox(width: 10),
                                    Text(localizedName),
                                  ],
                                ),
                              );
                            }).toList()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizer.pleaseSelectCategory;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          '${localizer.date}: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Icon(
                          Icons.calendar_today,
                          color: Colors.blue.shade700,
                        ),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField( // 👈 NEW DESCRIPTION FIELD
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: localizer.description,
                        border: const OutlineInputBorder(),
                        icon: const Icon(Icons.notes),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mintJade!.buttonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveEditedTransaction,
                      icon: const Icon(Icons.save),
                      label: Text(localizer.saveChanges),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveEditedTransaction() {
    if (_formKey.currentState!.validate()) {
      final updatedTransaction = Transaction(
        category: _category,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        isIncome: _isIncome,
        date: _selectedDate,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      Hive.box('transactions').put(widget.transactionKey, updatedTransaction);

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
              Navigator.of(context).pop(); // Go back
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
}
