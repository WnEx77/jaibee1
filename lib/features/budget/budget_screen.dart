import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jaibee/data/models/budget.dart';
import 'package:jaibee/data/models/category.dart';
import 'package:jaibee/shared/widgets/app_background.dart';
import 'package:jaibee/l10n/s.dart';
import 'package:jaibee/core/theme/mint_jade_theme.dart';
import 'package:jaibee/core/utils/category_utils.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/currency_utils.dart';

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
    final monthlyBudget = _budgetBox.get('__monthly__');
    setState(() {
      _monthlyLimit = monthlyBudget?.limit;
      _monthlyLimitController.text =
          (_monthlyLimit != null && _monthlyLimit! > 0)
          ? _monthlyLimit!.toStringAsFixed(0)
          : '';
    });
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

    final monthlyText = _monthlyLimitController.text.trim();
    final monthly = monthlyText.isEmpty ? null : double.tryParse(monthlyText);

    if (monthly == null || monthly < 0) {
      Flushbar(
        message: S.of(context)!.invalidMonthlyLimit,
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
      return;
    }

    if (monthly != totalCategoryLimits) {
      Flushbar(
        message: S
            .of(context)!
            .monthlyLimitValidation(
              monthly.toStringAsFixed(0),
              totalCategoryLimits.toStringAsFixed(0),
            ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
      return;
    }

    for (var category in _categoryBox.values) {
      final name = category.name;
      final controller = _controllers[name];
      final text = controller?.text.trim() ?? '';
      final limit = double.tryParse(text.isEmpty ? '0' : text) ?? 0;

      final budget = Budget(category: name, limit: limit);
      _budgetBox.put(name, budget);
    }

    final monthlyBudget = Budget(category: '__monthly__', limit: monthly);
    await _budgetBox.put('__monthly__', monthlyBudget);

    Flushbar(
      message: S.of(context)!.budgetsSaved,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(8),
      icon: const Icon(Icons.check_circle, color: Colors.white, size: 28),
    ).show(context);
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = _controllers.values
        .map((c) => double.tryParse(c.text) ?? 0)
        .fold(0.0, (a, b) => a + b);

    if (total == 0) return [];

    final entries = _controllers.entries.toList();

    final mintJade = Theme.of(context).extension<MintJadeColors>()!;
    final baseColor = mintJade.buttonColor;

    List<Color> generateShades(Color base, int count) {
      final hslBase = HSLColor.fromColor(base);

      return List.generate(count, (i) {
        final lightness = (0.9 - i * 0.08).clamp(0.2, 0.85);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = _categoryBox.values.toList();
    final monthlyLimitValue =
        double.tryParse(_monthlyLimitController.text) ?? 0;
    final totalCategoryLimits = _controllers.values
        .map((c) => double.tryParse(c.text) ?? 0)
        .fold(0.0, (a, b) => a + b);
    final remainingBudget = monthlyLimitValue - totalCategoryLimits;
    final pieSections = _buildPieChartSections();

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   foregroundColor: Theme.of(context).colorScheme.onSurface,
      //   elevation: 0,
      //   centerTitle: true,
      //   shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      //   ),
      //   title: Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Icon(
      //         Icons.account_balance_wallet_rounded,
      //         // No manual color, use theme
      //         size: 28,
      //       ),
      //       const SizedBox(width: 8),
      //       Text(
      //         S.of(context)!.monthlyBudget,
      //         style: Theme.of(
      //           context,
      //         ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      //       ),
      //     ],
      //   ),
      //   // actions: [
      //   //   IconButton(
      //   //     icon: const Icon(Icons.save),
      //   //     tooltip: S.of(context)!.save,
      //   //     onPressed: _saveBudgets,
      //   //   ),
      //   // ],
      // ),
body: AppBackground(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            // 1. Monthly Limit Section
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
                        const Icon(Icons.flag, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          S.of(context)!.monthlyLimit,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      S
                          .of(context)!
                          .setYourMonthlyLimit, // Add this to your l10n: "Set your total spending limit for the month."
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 10),
                    _styledContainer(
                      child: TextField(
                        controller: _monthlyLimitController,
                        keyboardType: TextInputType.number,
                        style: Theme.of(context).textTheme.titleLarge,
                        decoration: InputDecoration(
                          labelText: _monthlyLimitController.text.trim().isEmpty
                              ? S.of(context)!.enterMonthlyLimitHint
                              : null,
                          // prefixIcon: const Icon(Icons.attach_money),
                          border: InputBorder.none,
                          isDense: true,
                          errorText:
                              _isInvalidInput(_monthlyLimitController.text)
                              ? S.of(context)!.invalidMonthlyLimit
                              : null,
                        ),
                        onChanged: (_) => setState(() {}),
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
                      S
                          .of(context)!
                          .allocateToCategories, // Add to l10n: "Distribute your monthly limit across categories."
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    ...categories.map((category) {
                      final controller = _controllers[category.name];
                      final isEmpty = controller?.text.trim().isEmpty ?? true;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              getCategoryIcon(category),
                              color: isDark ? Colors.tealAccent : Colors.teal,
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
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: _styledContainer(
                                child: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    // prefixText: 'SAR ',
                                    labelText: isEmpty
                                        ? S.of(context)!.enterAmountHint
                                        : null,
                                    // suffixIcon: const Icon(
                                    //   Icons.edit,
                                    //   size: 18,
                                    //   color: Colors.grey,
                                    // ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onChanged: (_) => setState(() {}),
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

            // 3. Summary Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.summarize, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          S.of(context)!.summary,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildBudgetInfoRow(
                      S.of(context)!.limit,
                      monthlyLimitValue,
                    ),
                    _buildBudgetInfoRow(
                      S.of(context)!.allocated,
                      totalCategoryLimits,
                      highlight: true,
                    ),
                    _buildBudgetInfoRow(
                      S.of(context)!.remaining,
                      remainingBudget,
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: monthlyLimitValue == 0
                          ? 0
                          : (totalCategoryLimits / monthlyLimitValue).clamp(
                              0,
                              1,
                            ),
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        (totalCategoryLimits / monthlyLimitValue) >= 1
                            ? Colors.redAccent
                            : Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      S
                          .of(context)!
                          .summaryHint, // Add to l10n: "Allocated should match your monthly limit."
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Pie Chart Section
            // if (pieSections.isNotEmpty) ...[
            //   const SizedBox(height: 28),
            //   Card(
            //     elevation: 2,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(24),
            //     ),
            //     child: Padding(
            //       padding: const EdgeInsets.all(18),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Row(
            //             children: [
            //               const Icon(Icons.pie_chart, color: Colors.teal),
            //               const SizedBox(width: 8),
            //               Text(
            //                 S.of(context)!.budgetDistribution,
            //                 style: Theme.of(context).textTheme.titleMedium
            //                     ?.copyWith(fontWeight: FontWeight.bold),
            //               ),
            //             ],
            //           ),
            //           const SizedBox(height: 16),
            //           SizedBox(
            //             height: 220,
            //             child: PieChart(
            //               PieChartData(
            //                 sections: pieSections,
            //                 centerSpaceRadius: 40,
            //                 sectionsSpace: 2,
            //                 borderData: FlBorderData(show: false),
            //               ),
            //             ),
            //           ),
            //           const SizedBox(height: 12),
            //           Wrap(
            //             spacing: 8,
            //             children: categories.map((cat) {
            //               return Chip(
            //                 label: Text(
            //                   getLocalizedCategory(cat.name, S.of(context)!),
            //                 ),
            //                 // backgroundColor: getCategoryColor(
            //                 //   cat.name,
            //                 // ).withOpacity(0.18),
            //               );
            //             }).toList(),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ],

            // const SizedBox(height: 32),
            // 5. Info Footer
            Center(
              child: Text(
                S
                    .of(context)!
                    .budgetScreenFooter, // Add to l10n: "Tip: Adjust your limits anytime to stay on track!"
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.teal),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(S.of(context)!.save),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _saveBudgets,
              ),
            ),
          ],
        ),
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
