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

  void _confirmDelete() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                S.of(context)!.deleteTransaction,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                S.of(context)!.areYouSureDeleteTransaction,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(S.of(context)!.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete, size: 18),
                    label: Text(S.of(context)!.delete),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {
                      Hive.box('transactions').delete(widget.transactionKey);
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Return to previous
                      Flushbar(
                        message: S.of(context)!.transactionDeleted,
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.red,
                        margin: const EdgeInsets.all(8),
                        borderRadius: BorderRadius.circular(8),
                        flushbarPosition: FlushbarPosition.BOTTOM,
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                      ).show(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
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
                              borderSide: const BorderSide(color: Colors.teal, width: 1.5),
                            ),
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
                          items: _buildCategoryItems(localizer),
                          onChanged: _isIncome ? null : (val) => setState(() => _category = val!),
                          decoration: InputDecoration(
                            labelText: localizer.category,
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
                              borderSide: const BorderSide(color: Colors.teal, width: 1.5),
                            ),
                            icon: Icon(
                              getCategoryIcon(
                                _customCategories.firstWhere(
                                  (cat) => cat.name == _category,
                                  orElse: () => Category(name: _category, icon: ''),
                                ),
                              ),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(18),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
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
                              borderSide: const BorderSide(color: Colors.teal, width: 1.5),
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
    )
    );
  }
}
