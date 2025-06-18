import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart'; // <- PieChart package
import 'package:jaibee1/models/budget.dart';
import 'package:jaibee1/models/category.dart';
import 'package:jaibee1/widgets/app_background.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/providers/mint_jade_theme.dart';

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
      final controller = _controllers[category.name];
      final limit = double.tryParse(controller?.text ?? '') ?? -1;

      if (limit < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${localizeCategory(context, category.name)}: ${S.of(context)!.invalidLimit}',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      totalCategoryLimits += limit;
    }

    final monthly = double.tryParse(_monthlyLimitController.text) ?? -1;
    if (monthly < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)!.invalidMonthlyLimit),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

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

  String localizeCategory(BuildContext context, String name) {
    final s = S.of(context)!;
    switch (name.toLowerCase()) {
      case 'food':
        return s.food;
      case 'transport':
      case 'transportation':
        return s.transport;
      case 'entertainment':
        return s.entertainment;
      case 'coffee':
        return s.coffee;
      case 'income':
        return s.income;
      case 'shopping':
        return s.shopping;
      case 'health':
        return s.health;
      case 'bills':
        return s.bills;
      case 'home':
        return s.home;
      case 'groceries':
        return s.groceries;
      case 'beauty':
        return s.beauty;
      case 'electronics':
        return s.electronics;
      case 'books':
        return s.books;
      case 'petcare':
      case 'pet care':
        return s.petCare;
      case 'gifts':
        return s.gifts;
      case 'savings':
        return s.savings;
      case 'events':
        return s.events;
      case 'fitness':
        return s.fitness;
      case 'other':
        return s.other;
      default:
        return name;
    }
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = _controllers.values
        .map((c) => double.tryParse(c.text) ?? 0)
        .fold(0.0, (a, b) => a + b);

    if (total == 0) return [];

    final entries = _controllers.entries.toList();

    return List.generate(entries.length, (i) {
      final name = entries[i].key;
      final value = double.tryParse(entries[i].value.text) ?? 0;
      final percentage = (value / total) * 100;
      final color = Colors.primaries[i % Colors.primaries.length];

      return PieChartSectionData(
        title:
            '${localizeCategory(context, name)}\n${percentage.toStringAsFixed(1)}%',
        value: value,
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoryBox.values.toList();
    final mintTheme = Theme.of(context).extension<MintJadeColors>()!;
    final pieSections = _buildPieChartSections();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _saveBudgets,
        backgroundColor: mintTheme.buttonColor,
        foregroundColor: Colors.white,
        tooltip: S.of(context)!.save,
        child: const Icon(Icons.save),
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

            if (pieSections.isNotEmpty) ...[
               Text(
                S.of(context)!.budgetDistribution,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: pieSections,
                    centerSpaceRadius: 32,
                    sectionsSpace: 2,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Divider(),

            ...categories.map((category) {
              return Column(
                key: ValueKey(category.name), // Ensures uniqueness if reused
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          localizeCategory(context, category.name),
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
                          onChanged: (_) =>
                              setState(() {}), // Live chart update
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
