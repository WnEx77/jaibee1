import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jaibee1/models/trancs.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/screens/edit_tranc.dart';

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

  final Set<String> _selectedFilters = Set.from(defaultQuickCategories);
  final settingsBox = Hive.box<double>('settings');
  final String monthlyLimitKey = 'monthlyLimit';

  double _monthlyLimit = 0;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _monthlyLimit = settingsBox.get(monthlyLimitKey, defaultValue: 0.0) ?? 0.0;
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_selectedMonth.year == now.year && _selectedMonth.month == now.month) return;
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  void _showSetLimitDialog(BuildContext context, S localizer) {
    final controller = TextEditingController(
      text: _monthlyLimit > 0 ? _monthlyLimit.toStringAsFixed(2) : '',
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localizer.setMonthlyLimit),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: localizer.monthlyLimit,
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              final amount = double.tryParse(value ?? '');
              if (amount == null || amount < 0) {
                return localizer.invalidAmount;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizer.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final value = double.parse(controller.text);
                setState(() => _monthlyLimit = value);
                settingsBox.put(monthlyLimitKey, value);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(localizer.monthlyLimitSet)),
                );
              }
            },
            child: Text(localizer.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;
    final transactionBox = Hive.box('transactions');

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        title: Text(
          '${localizer.montlyLimitSetter} ${_monthlyLimit.toStringAsFixed(0)} ${localizer.sar}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: localizer.filterTransactions,
            onPressed: () => _showFilterDialog(context, localizer),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: localizer.setMonthlyLimit,
            onPressed: () => _showSetLimitDialog(context, localizer),
          ),
        ],
      ),
      body: ValueListenableBuilder(
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
              .where((t) => _selectedFilters.contains(t.category.toLowerCase()))
              .toList();

          for (var t in filteredTransactions) {
            if (t.isIncome) {
              totalIncome += t.amount;
            } else {
              totalExpenses += t.amount;
            }
          }

          final balance = totalIncome - totalExpenses;
          final progress = _monthlyLimit > 0
              ? (totalExpenses / _monthlyLimit).clamp(0.0, 1.0)
              : 0.0;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                              color: balance >= 0 ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                        if (_monthlyLimit > 0) ...[
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress < 0.7
                                  ? Colors.green
                                  : (progress < 1 ? Colors.orange : Colors.red),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${(progress * 100).toStringAsFixed(1)}% ${localizer.used}',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          final formattedDate = DateFormat.yMMMd().format(transaction.date);

                          return Dismissible(
                            key: Key(transaction.key.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) {
                              box.delete(transaction.key);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(localizer.transactionDeleted),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditTransactionScreen(
                                        transaction: transaction,
                                        transactionKey: transaction.key as int,
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
                                    color: isIncome ? Colors.green : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  _getLocalizedCategory(transaction.category, localizer),
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
                                    color: isIncome ? Colors.green : Colors.red,
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
              return SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: defaultQuickCategories.map((category) {
                    final label = _getLocalizedCategory(category, localizer);
                    return CheckboxListTile(
                      title: Text(label),
                      value: tempSelected.contains(category),
                      onChanged: (checked) {
                        setStateDialog(() {
                          if (checked == true) {
                            tempSelected.add(category);
                          } else {
                            tempSelected.remove(category);
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
                  _selectedFilters.clear();
                  _selectedFilters.addAll(tempSelected);
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
