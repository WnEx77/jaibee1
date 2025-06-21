import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart'; // <- PieChart package
import 'package:jaibee1/data/models/budget.dart';
import 'package:jaibee1/data/models/category.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/core/theme/mint_jade_theme.dart';
import 'package:jaibee1/core/utils/category_utils.dart';

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
        text: existingBudget.limit > 0
            ? existingBudget.limit.toStringAsFixed(0)
            : '',
      );
    }
  }

  Future<void> _loadMonthlyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble('monthly_limit');

    setState(() {
      _monthlyLimit = stored;
      _monthlyLimitController.text = (stored != null && stored > 0)
          ? stored.toStringAsFixed(0)
          : '';
    });
  }

  bool _isInvalidInput(String? text) {
    if (text == null || text.trim().isEmpty)
      return false; // Empty is OK, treated as 0
    return double.tryParse(text.trim()) == null;
  }

  Future<void> _saveBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    double totalCategoryLimits = 0;

    // Validate each category input
    for (var category in _categoryBox.values) {
      final controller = _controllers[category.name];
      final text = controller?.text.trim() ?? '';
      final limit = double.tryParse(text.isEmpty ? '0' : text);

      if (limit == null || limit < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${getLocalizedCategory(category.name, S.of(context)!)}: ${S.of(context)!.invalidLimit}',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      totalCategoryLimits += limit;
    }

    // Validate monthly limit
    final monthlyText = _monthlyLimitController.text.trim();
    final monthly = monthlyText.isEmpty ? null : double.tryParse(monthlyText);

    if (monthly == null || monthly < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)!.invalidMonthlyLimit),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Check if category limits match the monthly limit
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

    // Save category budgets using category name as the key
    for (var category in _categoryBox.values) {
      final name = category.name;
      final controller = _controllers[name];
      final text = controller?.text.trim() ?? '';
      final limit = double.tryParse(text.isEmpty ? '0' : text) ?? 0;

      final budget = Budget(category: name, limit: limit);
      _budgetBox.put(name, budget); // Use category name as key
    }

    // Save monthly limit to SharedPreferences
    await prefs.setDouble('monthly_limit', monthly);

    // Notify user of successful save
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.of(context)!.budgetsSaved)));
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = _controllers.values
        .map((c) => double.tryParse(c.text) ?? 0)
        .fold(0.0, (a, b) => a + b);

    if (total == 0) return [];

    final entries = _controllers.entries.toList();

    final mintTheme = Theme.of(context).extension<MintJadeColors>()!;
    final baseColor = mintTheme.buttonColor;

    List<Color> generateShades(Color base, int count) {
      final hslBase = HSLColor.fromColor(base);

      return List.generate(count, (i) {
        final lightness = (0.9 - i * 0.08).clamp(
          0.2,
          0.85,
        ); // Spread across light to dark
        final hsl = hslBase.withLightness(lightness);
        return hsl.toColor();
      });
    }

    final List<Color> pieColors = generateShades(baseColor, entries.length);

    return List.generate(entries.length, (i) {
      final name = entries[i].key;
      final value = double.tryParse(entries[i].value.text) ?? 0;
      final percentage = (value / total) * 100;

      return PieChartSectionData(
        title:
            '${getLocalizedCategory(name, S.of(context)!)}\n${percentage.toStringAsFixed(1)}%',
        value: value,
        color: pieColors[i % pieColors.length],
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

    // Calculate totals
    final totalCategoryLimits = _controllers.values
        .map((c) => double.tryParse(c.text) ?? 0)
        .fold(0.0, (a, b) => a + b);

    final monthlyLimitValue =
        double.tryParse(_monthlyLimitController.text.trim()) ?? 0;
    final isMismatch =
        monthlyLimitValue > 0 && totalCategoryLimits != monthlyLimitValue;
    final progressRatio = monthlyLimitValue > 0
        ? (totalCategoryLimits / monthlyLimitValue).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveBudgets,
        backgroundColor: mintTheme.buttonColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.save_rounded),
        label: Text(S.of(context)!.save),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            Text(
              S.of(context)!.monthlyBudgetLimit,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _monthlyLimitController,
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.titleMedium,
                  decoration: InputDecoration(
                    labelText: S.of(context)!.enterMonthlyLimitHint,
                    prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
                    filled: true,
                    fillColor: _isInvalidInput(_monthlyLimitController.text)
                        ? Colors.red.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.05),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            if (isMismatch) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressRatio.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressRatio > 1.0
                        ? Colors.red
                        : (progressRatio < 1.0 ? Colors.orange : Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                S
                    .of(context)!
                    .budgetProgressInfo(totalCategoryLimits, monthlyLimitValue),
                style: TextStyle(
                  fontSize: 13,
                  color: progressRatio > 1.0
                      ? Colors.red
                      : (progressRatio < 1.0
                          ? Colors.orange
                          : mintTheme.buttonColor),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 12),
            Divider(
              thickness: 1.2,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context)!.categoryBudgets,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...categories.map((category) {
              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                    Icon(
                      getCategoryIcon(category),
                      color: mintTheme.buttonColor,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Text(
                      getLocalizedCategory(category.name, S.of(context)!),
                      style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextField(
                      controller: _controllers[category.name],
                      keyboardType: TextInputType.number,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: S.of(context)!.limitLabel,
                        filled: true,
                        fillColor: _isInvalidInput(
                            _controllers[category.name]?.text,
                          )
                          ? Colors.red.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.05),
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                        ),
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      ),
                    ),
                    ],
                  ),
                ),
              );
            }).toList(),
            if (pieSections.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                S.of(context)!.budgetDistribution,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sections: pieSections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 3,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}
