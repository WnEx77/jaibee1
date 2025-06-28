import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jaibee/data/models/budget.dart';
import 'package:jaibee/data/models/category.dart';
import 'package:jaibee/shared/widgets/app_background.dart';
import 'package:jaibee/l10n/s.dart';
import 'package:jaibee/core/utils/category_utils.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/currency_utils.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Box<Category> _categoryBox;
  late Box<Budget> _budgetBox;

  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _categoryBox = Hive.box<Category>('categories');
    _budgetBox = Hive.box<Budget>('budgets');
    _loadMonthlyLimit();

    for (var category in _categoryBox.values) {
      final existingBudget = _budgetBox.values.firstWhere(
        (b) => b.category == category.name,
        orElse: () => Budget(category: category.name, limit: 0.0),
      );
      _controllers[category.name] = TextEditingController(
        text: existingBudget.limit > 0
            ? existingBudget.limit.toStringAsFixed(0)
            : '',
      );
      _focusNodes[category.name] = FocusNode();
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMonthlyLimit() async {
    setState(() {});
  }

  bool _isInvalidInput(String? text) {
    if (text == null || text.trim().isEmpty) {
      return false; // Empty is OK, treated as 0
    }
    return double.tryParse(text.trim()) == null;
  }

  Future<void> _saveBudgets() async {
    double totalCategoryLimits = 0;

    for (var category in _categoryBox.values) {
      final controller = _controllers[category.name];
      final text = controller?.text.trim() ?? '';
      final limit = double.tryParse(text.isEmpty ? '0' : text);

      if (limit == null || limit < 0) {
        Flushbar(
          message:
              '${getLocalizedCategory(category.name, S.of(context)!)}: ${S.of(context)!.invalidLimit}',
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(8),
        ).show(context);
        return;
      }

      totalCategoryLimits += limit;
    }

    for (var category in _categoryBox.values) {
      final name = category.name;
      final controller = _controllers[name];
      final text = controller?.text.trim() ?? '';
      final limit = double.tryParse(text.isEmpty ? '0' : text) ?? 0;

      final budget = Budget(category: name, limit: limit);
      _budgetBox.put(name, budget);
    }

    final monthlyBudget = Budget(
      category: '__monthly__',
      limit: totalCategoryLimits,
    );
    await _budgetBox.put('__monthly__', monthlyBudget);
  }

  Future<Widget> buildCurrencySymbolWidget(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('currency_code') ?? 'SAR';
    final currency = getCurrencyByCode(code);

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: ValueListenableBuilder(
          valueListenable: _categoryBox.listenable(),
          builder: (context, Box<Category> box, _) {
            final categories = box.values.toList();

            // Ensure 'other' is always last
            categories.sort((a, b) {
              if (a.name == 'other') return 1;
              if (b.name == 'other') return -1;
              return 0;
            });

            final totalCategoryLimits = categories
                .map((cat) => double.tryParse(_controllers[cat.name]?.text ?? '') ?? 0)
                .fold(0.0, (a, b) => a + b);

            return KeyboardActions(
              config: KeyboardActionsConfig(
                actions: _controllers.keys.map((name) {
                  return KeyboardActionsItem(
                    focusNode: _focusNodes[name]!,
                    toolbarButtons: [
                      (node) => TextButton(
                            onPressed: () => node.unfocus(),
                            child: const Text('Done'),
                          ),
                    ],
                  );
                }).toList(),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Monthly Limit Section (Read-only)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flag, color: Colors.teal),
                                const SizedBox(width: 10),
                                Text(
                                  S.of(context)!.monthlyLimit,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        content: Text(
                                          S.of(context)!.monthlyLimitAuto,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text(S.of(context)!.ok ?? 'OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.help_outline,
                                    color: Colors.teal,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.teal.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${totalCategoryLimits.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal[800],
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. Category Budgets Section
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.category, color: Colors.teal),
                                const SizedBox(width: 8),
                                Text(
                                  S.of(context)!.categoryBudgets,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              S.of(context)!.allocateToCategories,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 12),
                            ...categories.map((category) {
                              final controller = _controllers[category.name];
                              final isEmpty =
                                  controller?.text.trim().isEmpty ?? true;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      getCategoryIcon(category),
                                      color: isDark
                                          ? Colors.tealAccent
                                          : Colors.teal,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        getLocalizedCategory(
                                          category.name,
                                          S.of(context)!,
                                        ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: _styledContainer(
                                        child: TextField(
                                          controller: controller,
                                          focusNode: _focusNodes[category.name],
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge,
                                          decoration: InputDecoration(
                                            labelText: isEmpty
                                                ? S.of(context)!.enterAmountHint
                                                : null,
                                            border: InputBorder.none,
                                            isDense: true,
                                          ),
                                          onChanged: (_) async {
                                            setState(() {});
                                            await _saveBudgets();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 5. Info Footer
                    Center(
                      child: Text(
                        S.of(context)!.budgetScreenFooter,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.teal),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBudgetInfoRow(
    String label,
    double value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            '${value.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.teal : null,
            ),
          ),
        ],
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
}