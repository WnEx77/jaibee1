import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jaibee1/models/trancs.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/screens/edit_tranc.dart';
import 'package:jaibee1/screens/budget_screen.dart'; // Import BudgetScreen
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaibee1/widgets/app_background.dart'; // Import your background widget
import 'package:jaibee1/models/category.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  static const List<String> defaultQuickCategories = [
    'food',
    'coffee',
    'transportation',
    'entertainment',
    'income',
    'other',
  ];

  final Set<String> _selectedFilters = {'income'}; // Always includes 'income'
  List<String> _categoryNames = []; // Populated from Hive

  DateTime _selectedMonth = DateTime.now();

  double? _monthlyLimit; // retrieved from budget box

  @override
  void initState() {
    super.initState();
    _loadMonthlyLimit();
    _loadCategories();
  }

  Future<void> _loadMonthlyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _monthlyLimit = prefs.getDouble('monthly_limit');
    });
  }

  Future<void> _loadCategories() async {
    final categoryBox = Hive.box<Category>('categories');
    final categories = categoryBox.values
        .map((cat) => cat.name)
        .where((name) => name.toLowerCase() != 'income') // Exclude income
        .toList();

    setState(() {
      _categoryNames = categories;
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
    if (_selectedMonth.year == now.year && _selectedMonth.month == now.month)
      return;
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;
    final transactionBox = Hive.box('transactions');
    final categoryBox = Hive.box<Category>('categories');

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
                    .where(
                      (t) =>
                          t.date.month == _selectedMonth.month &&
                          t.date.year == _selectedMonth.year,
                    )
                    .toList();

                final filteredTransactions = allTransactions
                    .where(
                      (t) =>
                          _selectedFilters.contains(t.category.toLowerCase()),
                    )
                    .toList();

                for (var t in filteredTransactions) {
                  if (t.isIncome) {
                    totalIncome += t.amount;
                  } else {
                    totalExpenses += t.amount;
                  }
                }

                final balance = totalIncome - totalExpenses;
                double usagePercent = 0;
                if (_monthlyLimit != null && _monthlyLimit! > 0) {
                  usagePercent = (totalExpenses / _monthlyLimit!).clamp(0, 1);
                }

                return Column(
                  children: [
                    // 🔼 Monthly summary card remains unchanged
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                                    Text(
                                      '\$${totalExpenses.toStringAsFixed(2)} / \$${_monthlyLimit!.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: usagePercent >= 1
                                            ? Colors.red
                                            : Colors.green,
                                      ),
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
                                    _selectedMonth.year == DateTime.now().year)
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
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 🔼 Month navigation remains unchanged
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

                    // 🔼 Transaction list
                    Expanded(
                      child: filteredTransactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.money_off,
                                    size: 80,
                                    color: Colors.grey.shade400,
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
                                  onDismissed: (_) {
                                    box.delete(transaction.key);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localizer.transactionDeleted,
                                        ),
                                      ),
                                    );
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
                                        backgroundColor: isIncome
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        child: Icon(
                                          isIncome
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          color: isIncome
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      title: Text(
                                        _getLocalizedCategory(
                                          transaction.category,
                                          localizer,
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(formattedDate),
                                      trailing: Text(
                                        (isIncome ? '+ ' : '- ') +
                                            '\$${transaction.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isIncome
                                              ? Colors.green
                                              : Colors.red,
                                        ),
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

  void _showFilterDialog(BuildContext context, S localizer) {
    final tempSelected = Set<String>.from(_selectedFilters);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizer.filterTransactions),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              final allCategories = ['income', ..._categoryNames];

              return SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: allCategories.map((categoryName) {
                    final label = _getLocalizedCategory(
                      categoryName,
                      localizer,
                    );
                    return CheckboxListTile(
                      title: Text(label),
                      value: tempSelected.contains(categoryName),
                      onChanged: categoryName == 'income'
                          ? null // Disable unchecking for income
                          : (checked) {
                              setStateDialog(() {
                                if (checked == true) {
                                  tempSelected.add(categoryName);
                                } else {
                                  tempSelected.remove(categoryName);
                                }
                              });
                            },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizer.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedFilters
                    ..clear()
                    ..add('income') // Always keep income
                    ..addAll(tempSelected.where((c) => c != 'income'));
                });
                Navigator.pop(context);
              },
              child: Text(localizer.ok),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryItem({
    required String title,
    required double amount,
    required Color color,
  }) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getLocalizedCategory(String key, S localizer) {
    switch (key.toLowerCase()) {
      case 'food':
        return localizer.food;
      case 'coffee':
        return localizer.coffee;
      case 'transportation':
        return localizer.transportation;
      case 'entertainment':
        return localizer.entertainment;
      case 'income':
        return localizer.income;
      case 'other':
        return localizer.other;
      default:
        return key;
    }
  }

  IconData _getIconForCategory(String key) {
    switch (key.toLowerCase()) {
      case 'food':
        return Icons.fastfood;
      case 'coffee':
        return Icons.coffee;
      case 'transportation':
        return Icons.directions_bus;
      case 'entertainment':
        return Icons.movie;
      case 'income':
        return Icons.attach_money;
      case 'other':
        return Icons.category;
      default:
        return Icons.category;
    }
  }
}
