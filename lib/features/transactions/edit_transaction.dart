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
import 'package:jaibee1/core/utils/category_utils.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:jaibee1/core/utils/currency_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaibee1/shared/widgets/global_date_picker.dart';
import 'package:jaibee1/shared/widgets/global_confirm_delete_dialog.dart';

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
    final picked = await showGlobalCupertinoDatePicker(
      context: context,
      initialDate: _selectedDate,
      minDate: DateTime(2000),
      maxDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
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

      // Show a Flushbar instead of SnackBar
      // Make sure to add flushbar package in pubspec.yaml: flushbar: ^1.10.4
      // import 'package:flushbar/flushbar.dart'; at the top of the file

      Flushbar(
        message: S.of(context)!.transactionUpdated,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.BOTTOM,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      ).show(context).then((_) {
        Navigator.of(context).pop();
      });
    }
  }

  void _confirmDelete() async {
    final localizer = S.of(context)!;
    final confirmed = await showGlobalConfirmDeleteDialog(
      context: context,
      title: localizer.deleteTransaction,
      message: localizer.areYouSureDeleteTransaction,
    );
    if (confirmed == true) {
      Hive.box('transactions').delete(widget.transactionKey);
      Navigator.of(context).pop(); // Close dialog
      Navigator.of(context).pop(); // Return to previous
      Flushbar(
        message: localizer.transactionDeleted,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.BOTTOM,
        icon: const Icon(
          Icons.check_circle,
          color: Colors.white,
        ),
      ).show(context);
    }
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
        final name = getLocalizedCategory(cat.name, localizer);
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

  Future<Widget> buildCurrencySymbolWidget(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('currency_code') ?? 'SAR';
    final currency = getCurrencyByCode(code);

    // Use theme from context for dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = currency.getAsset(isDarkMode: isDark);
    if (asset != null) {
      return Image.asset(asset, width: 22, height: 22);
    } else {
      return Text(currency.symbol, style: const TextStyle(fontSize: 22));
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 380, // Make the box smaller on wide screens
                ),
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
                        shrinkWrap: true,
                        children: [
                          FutureBuilder<Widget>(
                            future: buildCurrencySymbolWidget(context),
                            builder: (context, snapshot) {
                              return TextFormField(
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
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[900]
                                      : Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[800]!
                                          : Colors.grey[200]!,
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: const BorderSide(
                                      color: Colors.teal,
                                      width: 1.5,
                                    ),
                                  ),
                                  icon: snapshot.hasData
                                      ? snapshot.data
                                      : const SizedBox(width: 24, height: 24),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return localizer.pleaseEnterAmount;
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            value: _category.isNotEmpty ? _category : null,
                            items: _buildCategoryItems(localizer),
                            onChanged: _isIncome
                                ? null
                                : (val) => setState(() => _category = val!),
                            decoration: InputDecoration(
                              labelText: localizer.category,
                              border: InputBorder.none,
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[900]
                                  : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[800]!
                                      : Colors.grey[200]!,
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Colors.teal,
                                  width: 1.5,
                                ),
                              ),
                              icon: Icon(
                                getCategoryIcon(
                                  _customCategories.firstWhere(
                                    (cat) => cat.name == _category,
                                    orElse: () =>
                                        Category(name: _category, icon: ''),
                                  ),
                                ),
                              ),
                            ),
                            borderRadius: BorderRadius.circular(18),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 28,
                            ),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () => _selectDate(context),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: localizer.description,
                              border: InputBorder.none,
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[900]
                                  : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[800]!
                                      : Colors.grey[200]!,
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Colors.teal,
                                  width: 1.5,
                                ),
                              ),
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
        ),
      ),
    );
  }
}
