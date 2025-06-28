import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
// import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jaibee/data/models/trancs.dart';
import 'package:jaibee/data/models/category.dart';
import 'package:jaibee/l10n/s.dart';
import 'package:jaibee/shared/widgets/app_background.dart';
import 'package:jaibee/core/theme/mint_jade_theme.dart';
import 'package:jaibee/core/utils/category_utils.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/currency_utils.dart';
import 'package:jaibee/shared/widgets/global_date_picker.dart';
import 'package:jaibee/data/models/budget.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  final FocusNode _amountFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  String _category = '';
  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // No need to load categories here, handled by ValueListenableBuilder
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
            child: KeyboardActions(
              config: KeyboardActionsConfig(
                actions: [
                  KeyboardActionsItem(
                    focusNode: _amountFocus,
                    toolbarButtons: [
                      (node) => TextButton(
                        onPressed: () => node.unfocus(),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  KeyboardActionsItem(
                    focusNode: _descriptionFocus,
                    toolbarButtons: [
                      (node) => TextButton(
                        onPressed: () => node.unfocus(),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAmountField(localizer),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable: Hive.box<Category>(
                        'categories',
                      ).listenable(),
                      builder: (context, Box<Category> box, _) {
                        final categories = box.values.toList();
                        return _buildCategoryDropdown(localizer, categories);
                      },
                    ),
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
      ),
    );
  }

  String convertArabicDigitsToEnglish(String input) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < arabicDigits.length; i++) {
      input = input.replaceAll(arabicDigits[i], i.toString());
    }
    return input;
  }

  Widget _buildAmountField(S localizer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _styledContainer(
      child: FutureBuilder<Widget>(
        future: buildCurrencySymbolWidget(),
        builder: (context, snapshot) {
          return TextFormField(
            controller: _amountController,
            focusNode: _amountFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizer.pleaseEnterAmount;
              }
              final englishValue = convertArabicDigitsToEnglish(value);
              final numValue = double.tryParse(englishValue);
              if (numValue == null || numValue <= 0) {
                return localizer.enterValidAmount;
              }
              return null;
            },
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: localizer.amount,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child:
                    snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData
                    ? snapshot.data!
                    : SizedBox(width: 24, height: 24),
              ),
              border: InputBorder.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryDropdown(S localizer, List<Category> categories) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

      // Sort so 'other' is always last
  categories.sort((a, b) {
    if (a.name == 'other') return 1;
    if (b.name == 'other') return -1;
    return 0;
  });
  
    final dropdownCategories = _isIncome
        ? [Category(name: 'income', icon: 'attach_money')]
        : categories;

    final categoryNames = dropdownCategories.map((c) => c.name).toList();

    // Reset _category if it's no longer valid
    if (_category.isNotEmpty && !categoryNames.contains(_category)) {
      _category = '';
    }

    // Set default if needed
    if (!_isIncome && dropdownCategories.isNotEmpty && _category.isEmpty) {
      _category = dropdownCategories.first.name;
    } else if (_isIncome) {
      _category = 'income';
    }

    return _styledContainer(
      child: DropdownButtonFormField<String>(
        value: _category.isNotEmpty ? _category : null,
        items: dropdownCategories.map((cat) {
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
              _category = _isIncome ? 'income' : '';
            });
          },
          borderRadius: BorderRadius.circular(12),
          borderWidth: 1.5,
          selectedColor: selectedTextColor,
          fillColor: _isIncome ? Colors.green : Colors.redAccent,
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
        focusNode: _descriptionFocus,
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
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(S localizer) {
    final mintJade = Theme.of(context).extension<MintJadeColors>()!;
    return FilledButton.icon(
      onPressed: _submitForm,
      style: FilledButton.styleFrom(
        backgroundColor: mintJade.buttonColor,
        foregroundColor: Colors.white,
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
        amount:
            double.tryParse(
              convertArabicDigitsToEnglish(_amountController.text),
            ) ??
            0.0,
        isIncome: _isIncome,
        date: _selectedDate,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      // Check if limit is exceeded for this category (only for expenses)
      bool exceededLimit = false;
      if (!_isIncome) {
        final budgetBox = Hive.box<Budget>(
          'budgets',
        ); // Do NOT open the box again!
        final budget = budgetBox.get(_category);
        if (budget != null) {
          final categoryLimit = budget.limit;
          // Calculate total spent for this category this month
          final transactionBox = Hive.box('transactions');
          final now = DateTime.now();
          final totalSpent = transactionBox.values
              .where(
                (t) =>
                    t is Transaction &&
                    t.category == _category &&
                    !t.isIncome &&
                    t.date.year == now.year &&
                    t.date.month == now.month,
              )
              .fold<double>(0.0, (sum, t) => sum + (t.amount as double));
          if (totalSpent + transaction.amount > categoryLimit) {
            exceededLimit = true;
          }
        }
      }

      Hive.box('transactions').add(transaction);

      setState(() {
        _amountController.clear();
        _descriptionController.clear();
        _isIncome = false;
        _selectedDate = DateTime.now();
        _category = '';
      });

      Navigator.of(context).pushReplacementNamed('/transactions');

      Flushbar(
        message: exceededLimit
            ? localizer.categoryLimitExceeded
            : localizer.transactionAdded,
        duration: const Duration(seconds: 2),
        backgroundColor: exceededLimit ? Colors.red : Colors.green,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        icon: Icon(
          exceededLimit ? Icons.warning_amber_rounded : Icons.check_circle,
          color: Colors.white,
        ),
      ).show(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showGlobalCupertinoDatePicker(
      context: context,
      initialDate: _selectedDate,
      minDate: DateTime(2000),
      maxDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<Widget> buildCurrencySymbolWidget() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('currency_code') ?? 'SAR';
    final currency = getCurrencyByCode(code);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.tealAccent : Colors.teal;

    if (currency.asset != null) {
      return Image.asset(
        currency.asset!,
        width: 22,
        height: 22,
        color: iconColor,
      );
    } else {
      return Text(
        currency.symbol,
        style: TextStyle(fontSize: 22, color: iconColor),
      );
    }
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

  Route createAnimatedRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Combine fade and slide for a smooth effect
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }
}
