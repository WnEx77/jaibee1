import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jaibee1/data/models/trancs.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/features/transactions/edit_transaction.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/data/models/category.dart';
import 'package:jaibee1/core/theme/mint_jade_theme.dart';
import 'package:jaibee1/features/transactions/category_progress_screen.dart';
import 'package:jaibee1/core/utils/category_utils.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:jaibee1/data/models/budget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/currency_utils.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final Set<String> _selectedFilters = {'income'}; // Always includes 'income'
  DateTime _selectedMonth = DateTime.now();
  String _selectedPeriod = 'monthly'; // 'daily', 'weekly', 'monthly'
  double? _monthlyLimit; // retrieved from budget box

  @override
  void initState() {
    super.initState();
    _loadMonthlyLimit();
    _loadCategories();
  }

  Future<void> _loadMonthlyLimit() async {
    final budgetBox = Hive.box<Budget>('budgets');
    final monthlyBudget = budgetBox.get('__monthly__');
    setState(() {
      _monthlyLimit = monthlyBudget?.limit;
    });
  }

  Future<void> _loadCategories() async {
    final categoryBox = Hive.box<Category>('categories');
    final categories = categoryBox.values
        .map((cat) => cat.name)
        .where((name) => name.toLowerCase() != 'income') // Exclude income
        .toList();

    setState(() {
      _selectedFilters.addAll(categories); // Select all by default
    });
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_selectedMonth.year == now.year && _selectedMonth.month == now.month) {
      return;
    }
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  Future<Widget> buildCurrencySymbolWidget(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('currency_code') ?? 'SAR';
    final currency = getCurrencyByCode(code);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = currency.getAsset(isDarkMode: isDark);
    if (asset != null) {
      return Image.asset(asset, width: 18, height: 18, color: color);
    } else {
      return Text(currency.symbol, style: TextStyle(fontSize: 18, color: color));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;
    final transactionBox = Hive.box('transactions');
    final categoryBox = Hive.box<Category>('categories');
    final mintTheme = Theme.of(context).extension<MintJadeColors>()!;

    return Scaffold(
      body: AppBackground(
        child: ValueListenableBuilder(
          valueListenable: categoryBox.listenable(),
          builder: (context, Box<Category> categoryBox, _) {
            final currentCategories = categoryBox.values
                .map((c) => c.name.toLowerCase())
                .where((name) => name != 'income')
                .toList();

            // Maintain consistency in selected filters
            _selectedFilters.removeWhere(
              (cat) => cat != 'income' && !currentCategories.contains(cat),
            );
            for (final cat in currentCategories) {
              _selectedFilters.add(cat);
            }

            return ValueListenableBuilder(
              valueListenable: transactionBox.listenable(),
              builder: (context, Box box, _) {
                double totalIncome = 0;
                double totalExpenses = 0;

                final allTransactions = box.values
                    .whereType<Transaction>()
                    .where((t) {
                      if (_selectedPeriod == 'daily') {
                        return t.date.year == _selectedMonth.year &&
                            t.date.month == _selectedMonth.month &&
                            t.date.day == _selectedMonth.day;
                      } else if (_selectedPeriod == 'weekly') {
                        final weekDay = _selectedMonth.weekday;
                        final weekStart = _selectedMonth.subtract(
                          Duration(days: weekDay - 1),
                        );
                        final weekEnd = weekStart.add(const Duration(days: 6));
                        return !t.date.isBefore(weekStart) &&
                            !t.date.isAfter(weekEnd);
                      } else {
                        // monthly
                        return t.date.year == _selectedMonth.year &&
                            t.date.month == _selectedMonth.month;
                      }
                    })
                    .toList();

                final filteredTransactions = allTransactions
                    .where(
                      (t) =>
                          _selectedFilters.contains(t.category.toLowerCase()),
                    )
                    .toList()
                    ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending

                for (var t in filteredTransactions) {
                  if (t.isIncome) {
                    totalIncome += t.amount;
                  } else if (t.category.toLowerCase() != 'savings') {
                    totalExpenses += t.amount;
                  }
                }
                final totalSavings = allTransactions
                    .where((t) => t.category.toLowerCase() == 'savings')
                    .fold<double>(0, (sum, t) => sum + t.amount);
                final balance = totalIncome - totalExpenses - totalSavings;

                double usagePercent = 0;
                if (_monthlyLimit != null && _monthlyLimit! > 0) {
                  usagePercent = (totalExpenses / _monthlyLimit!).clamp(0, 1);
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryProgressScreen(
                                selectedMonth: _selectedMonth,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            child: Column(
                              children: [
                                if (_monthlyLimit != null) ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        localizer.monthlyLimit,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            totalExpenses.toStringAsFixed(2),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: usagePercent >= 1
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          FutureBuilder<Widget>(
                                            future: buildCurrencySymbolWidget(
                                              usagePercent >= 1
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                                return snapshot.data!;
                                              }
                                              return const SizedBox(width: 16, height: 16);
                                            },
                                          ),
                                          Text(
                                            ' / ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: usagePercent >= 1
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                          ),
                                          Text(
                                            _monthlyLimit!.toStringAsFixed(2),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: usagePercent >= 1
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          FutureBuilder<Widget>(
                                            future: buildCurrencySymbolWidget(
                                              usagePercent >= 1
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                                return snapshot.data!;
                                              }
                                              return const SizedBox(width: 16, height: 16);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: LinearProgressIndicator(
                                      value: usagePercent,
                                      minHeight: 10,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        usagePercent < 0.6
                                            ? Colors.green
                                            : usagePercent < 0.9
                                                ? Colors.orange
                                                : Colors.red,
                                      ),
                                    ),
                                  ),
                                  if (_selectedMonth.month ==
                                          DateTime.now().month &&
                                      _selectedMonth.year ==
                                          DateTime.now().year)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day - DateTime.now().day} ${localizer.daysRemaining}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                ],
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _summaryItem(
                                      title: localizer.totalIncome,
                                      amount: totalIncome,
                                      color: Colors.green,
                                    ),
                                    _summaryItem(
                                      title: localizer.totalExpenses,
                                      amount: totalExpenses,
                                      color: Colors.red,
                                    ),
                                    _summaryItem(
                                      title: localizer.balance,
                                      amount: balance,
                                      color: balance >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  localizer.clickForMoreInfo,
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Month navigation
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios),
                            onPressed: _previousMonth,
                          ),
                          Text(
                            DateFormat.yMMM().format(_selectedMonth),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: Row(
                              children: [
                                const Icon(Icons.today, size: 18),
                                const SizedBox(width: 4),
                                Text(localizer.daily),
                              ],
                            ),
                            selected: _selectedPeriod == 'daily',
                            selectedColor: Colors.blue.shade100,
                            backgroundColor: Colors.grey.shade200,
                            labelStyle: TextStyle(
                              color: _selectedPeriod == 'daily'
                                  ? Colors.blue.shade800
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _selectedPeriod = 'daily';
                                _selectedMonth = DateTime.now();
                              });
                            },
                          ),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            label: Row(
                              children: [
                                const Icon(Icons.calendar_view_week, size: 18),
                                const SizedBox(width: 4),
                                Text(localizer.weekly),
                              ],
                            ),
                            selected: _selectedPeriod == 'weekly',
                            selectedColor: Colors.orange.shade100,
                            backgroundColor: Colors.grey.shade200,
                            labelStyle: TextStyle(
                              color: _selectedPeriod == 'weekly'
                                  ? Colors.orange.shade800
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _selectedPeriod = 'weekly';
                                _selectedMonth = DateTime.now();
                              });
                            },
                          ),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            label: Row(
                              children: [
                                const Icon(Icons.calendar_month, size: 18),
                                const SizedBox(width: 4),
                                Text(localizer.monthly),
                              ],
                            ),
                            selected: _selectedPeriod == 'monthly',
                            selectedColor: Colors.green.shade100,
                            backgroundColor: Colors.grey.shade200,
                            labelStyle: TextStyle(
                              color: _selectedPeriod == 'monthly'
                                  ? Colors.green.shade800
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _selectedPeriod = 'monthly';
                                _selectedMonth = DateTime.now();
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Transaction list
                    Expanded(
                      child: filteredTransactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FutureBuilder<Widget>(
                                    future: buildCurrencySymbolWidget(
                                      Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                        return SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: Center(
                                            child: Opacity(
                                              opacity: 0.4,
                                              child: snapshot.data!,
                                            ),
                                          ),
                                        );
                                      }
                                      return SizedBox(
                                        width: 80,
                                        height: 80,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Text(localizer.noTransactions),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredTransactions.length,
                              itemBuilder: (context, index) {
                                final transaction = filteredTransactions[index];
                                final isIncome = transaction.isIncome;
                                final formattedDate = DateFormat.yMMMd().format(
                                  transaction.date,
                                );
                                final amountColor = isIncome ? Colors.green : Colors.red;

                                return Dismissible(
                                  key: Key(transaction.key.toString()),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss: (direction) async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.red,
                                                size: 48,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                localizer.confirmDeletion,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                localizer
                                                    .areYouSureDeleteTransaction,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: Text(
                                                      localizer.cancel,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      localizer.delete,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );

                                    if (confirm == true) {
                                      box.delete(transaction.key);
                                      Flushbar(
                                        message: localizer.transactionDeleted,
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: Colors.redAccent,
                                        margin: const EdgeInsets.all(16),
                                        borderRadius: BorderRadius.circular(12),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ).show(context);
                                      return true;
                                    }
                                    return false;
                                  },

                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditTransactionScreen(
                                                  transaction: transaction,
                                                  transactionKey:
                                                      transaction.key as int,
                                                ),
                                          ),
                                        );
                                      },
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        child: Icon(
                                          getCategoryIcon(
                                            categoryBox.values.firstWhere(
                                              (cat) =>
                                                  cat.name == transaction.category,
                                              orElse: () => Category(
                                                name: transaction.category,
                                                icon: 'category',
                                              ),
                                            ),
                                          ),
                                          color: mintTheme.unselectedIconColor,
                                        ),
                                      ),
                                      title: Text(
                                        getLocalizedCategory(
                                          transaction.category,
                                          localizer,
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(formattedDate),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            isIncome ? '+ ' : '- ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: amountColor,
                                            ),
                                          ),
                                          Text(
                                            transaction.amount.toStringAsFixed(2),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: amountColor,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          FutureBuilder<Widget>(
                                            future: buildCurrencySymbolWidget(amountColor),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                                return snapshot.data!;
                                              }
                                              return const SizedBox(width: 16, height: 16);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _summaryItem({
    required String title,
    required double amount,
    required Color color,
  }) {
    return Column(
      children: [
        Text(title),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amount.toStringAsFixed(2),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            FutureBuilder<Widget>(
              future: buildCurrencySymbolWidget(color),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  return snapshot.data!;
                }
                return SizedBox(width: 16, height: 16);
              },
            ),
          ],
        ),
      ],
    );
  }
}