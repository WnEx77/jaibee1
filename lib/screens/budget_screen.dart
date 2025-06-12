import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaibee1/models/budget.dart';
import 'package:jaibee1/models/category.dart';

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
        text: existingBudget.limit.toString(),
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

    // Save category budgets
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

    // Save monthly limit
    final monthly = double.tryParse(_monthlyLimitController.text) ?? 0;
    await prefs.setDouble('monthly_limit', monthly);

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budgets saved')),
    );

    // Pop with 'true' to notify caller screen to reload
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoryBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        backgroundColor: const Color.fromARGB(255, 130, 148, 179),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBudgets,
            tooltip: 'Save Budgets',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Monthly limit input
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Monthly Budget Limit',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _monthlyLimitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'e.g. 1000',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
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
                        decoration: const InputDecoration(
                          labelText: 'Limit',
                          border: OutlineInputBorder(),
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
    );
  }
}
