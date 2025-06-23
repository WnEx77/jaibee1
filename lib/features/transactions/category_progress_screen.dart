import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:intl/intl.dart';
import 'package:jaibee1/data/models/trancs.dart';
import 'package:jaibee1/data/models/category.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/core/theme/mint_jade_theme.dart';
import 'package:jaibee1/shared/widgets/custom_app_bar.dart';
import 'package:jaibee1/data/models/budget.dart';
import 'package:jaibee1/core/utils/category_utils.dart';
import 'package:jaibee1/core/utils/currency_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProgressScreen extends StatelessWidget {
  final DateTime selectedMonth;

  const CategoryProgressScreen({super.key, required this.selectedMonth});

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
    final transactionBox = Hive.box('transactions');
    final categoryBox = Hive.box<Category>('categories');
    final budgetBox = Hive.box<Budget>('budgets'); // <-- Add this line
    final mintTheme = Theme.of(context).extension<MintJadeColors>()!;

    return Scaffold(
      appBar: CustomAppBar(
        title: localizer.categoryProgress,
        showBackButton: true,
      ),
      body: AppBackground(
        child: ValueListenableBuilder(
          valueListenable: categoryBox.listenable(),
          builder: (context, Box<Category> catBox, _) {
            final categories = catBox.values
                .where((c) => c.name.toLowerCase() != 'income')
                .toList();

            return ValueListenableBuilder(
              valueListenable: transactionBox.listenable(),
              builder: (context, Box box, _) {
                // Get all transactions for the selected month
                final transactions = box.values
                    .whereType<Transaction>()
                    .where(
                      (t) =>
                          t.date.year == selectedMonth.year &&
                          t.date.month == selectedMonth.month,
                    )
                    .toList();

                // Calculate total spent per category
                final Map<String, double> spentPerCategory = {};
                for (final cat in categories) {
                  final spent = transactions
                      .where(
                        (t) =>
                            t.category.toLowerCase() ==
                                cat.name.toLowerCase() &&
                            !t.isIncome,
                      )
                      .fold<double>(0, (sum, t) => sum + t.amount);
                  spentPerCategory[cat.name] = spent;
                }

                if (categories.isEmpty) {
                  return Center(child: Text(localizer.noCategories));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final spent = spentPerCategory[cat.name] ?? 0;

                    // Get the original limit for this category
                    final budget = budgetBox.get(cat.name);
                    final originalLimit = budget != null ? budget.limit : 0.0;

                    // Calculate percent of limit used
                    final percent = (originalLimit > 0)
                        ? (spent / originalLimit).clamp(0.0, 1.0)
                        : 0.0;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            getCategoryIcon(cat),
                            color: mintTheme.unselectedIconColor,
                          ),
                        ),
                        title: Text(
                          getLocalizedCategory(cat.name, localizer),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: percent,
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                percent < 0.6
                                    ? Colors.green
                                    : percent < 0.9
                                    ? Colors.orange
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (originalLimit > 0)
                              Text(
                                '${(percent * 100).toStringAsFixed(1)}% ${localizer.ofLimit}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              )
                            else
                              Text(
                                localizer.noLimitSet,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            if (originalLimit > 0)
                              Text(
                                '${localizer.limit}: ${originalLimit.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              spent.toStringAsFixed(2),
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            FutureBuilder<Widget>(
                              future: buildCurrencySymbolWidget(context),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  final widget = snapshot.data!;
                                  // Wrap the currency widget in a red DefaultTextStyle or IconTheme
                                  if (widget is Text) {
                                    return Text(
                                      widget.data ?? '',
                                      style:
                                          widget.style?.copyWith(
                                            color: Colors.red,
                                          ) ??
                                          const TextStyle(
                                            color: Colors.red,
                                            fontSize: 22,
                                          ),
                                    );
                                  } else {
                                    // For Image.asset, wrap with IconTheme for color if possible, else just return
                                    return ColorFiltered(
                                      colorFilter: const ColorFilter.mode(
                                        Colors.red,
                                        BlendMode.srcIn,
                                      ),
                                      child: widget,
                                    );
                                  }
                                }
                                return const SizedBox(width: 16, height: 16);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
