import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaibee1/models/budget.dart';
import 'package:jaibee1/models/category.dart';
import 'package:jaibee1/widgets/app_background.dart';
import 'package:jaibee1/l10n/s.dart'; // <-- Localization import

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Box<Category> _categoryBox;
  late Box<Budget> _budgetBox;

  double? _monthlyLimit;
  final TextEditingController _monthlyLimitController = TextEditingController();

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
        text: existingBudget.limit.toStringAsFixed(0),
      );
    }
  }

  Future<void> _loadMonthlyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _monthlyLimit = prefs.getDouble('monthly_limit') ?? 0;
      _monthlyLimitController.text = _monthlyLimit!.toStringAsFixed(0);
    });
  }

  Future<void> _saveBudgets() async {
    final prefs = await SharedPreferences.getInstance();

    double totalCategoryLimits = 0;

    for (var category in _categoryBox.values) {
      final name = category.name;
      final controller = _controllers[name];
      final limit = double.tryParse(controller?.text ?? '0') ?? 0;
      totalCategoryLimits += limit;
    }

    final monthly = double.tryParse(_monthlyLimitController.text) ?? 0;

    if (monthly != totalCategoryLimits) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S
                .of(context)!
                .monthlyLimitValidation(
                  monthly.toStringAsFixed(0),
                  totalCategoryLimits.toStringAsFixed(0),
                ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    for (var category in _categoryBox.values) {
      final name = category.name;
      final controller = _controllers[name];
      final limit = double.tryParse(controller?.text ?? '0') ?? 0;

      final existing = _budgetBox.values.firstWhere(
        (b) => b.category == name,
        orElse: () => Budget(category: name, limit: 0),
      );

      if (existing.isInBox) {
        existing.limit = limit;
        existing.save();
      } else {
        _budgetBox.add(Budget(category: name, limit: limit));
      }
    }

    await prefs.setDouble('monthly_limit', monthly);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.of(context)!.budgetsSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoryBox.values.toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveBudgets,
        label: Text(S.of(context)!.save),
        icon: const Icon(Icons.save),
        backgroundColor: const Color.fromARGB(255, 130, 148, 179),
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 24),
            Text(
              S.of(context)!.monthlyBudgetLimit,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _monthlyLimitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: S.of(context)!.enterMonthlyLimitHint,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),

            // Category budget inputs
            ...categories.map((category) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          category.name,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _controllers[category.name],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: S.of(context)!.limitLabel,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
