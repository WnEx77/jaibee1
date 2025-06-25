import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jaibee/data/models/trancs.dart';
import 'package:jaibee/l10n/s.dart';
import 'package:jaibee/features/transactions/edit_transaction.dart';
import 'package:jaibee/shared/widgets/app_background.dart';
import 'package:jaibee/data/models/category.dart';
import 'package:jaibee/core/theme/mint_jade_theme.dart';
import 'package:jaibee/features/categories/category_progress_screen.dart';
import 'package:jaibee/core/utils/category_utils.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:jaibee/data/models/budget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/currency_utils.dart';
import 'package:jaibee/shared/widgets/global_date_picker.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final Set<String> _selectedFilters = {'income'};
  DateTime _selectedMonth = DateTime.now();
  String _selectedPeriod = 'monthly';
  double? _monthlyLimit;
  DateTimeRange? _selectedRange;
  String _selectedCategory = 'all';

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
        .map((cat) => cat.name.toLowerCase())
        .where((name) => name != 'income')
        .toList();

    setState(() {
      _selectedFilters.addAll(categories);
    });
  }

  void _previousPeriod() {
    setState(() {
      if (_selectedPeriod == 'daily') {
        _selectedMonth = _selectedMonth.subtract(const Duration(days: 1));
      } else {
        _selectedMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month - 1,
        );
      }
    });
  }

  void _nextPeriod() {
    final now = DateTime.now();
    if (_selectedPeriod == 'daily') {
      final today = DateTime(now.year, now.month, now.day);
      final nextDay = DateTime(
        _selectedMonth.year,
        _selectedMonth.month,
        _selectedMonth.day,
      ).add(const Duration(days: 1));
      if (!nextDay.isAfter(today)) {
        setState(() {
          _selectedMonth = nextDay;
        });
      }
    } else {
      if (_selectedMonth.year == now.year && _selectedMonth.month == now.month)
        return;
      setState(() {
        _selectedMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month + 1,
        );
      });
    }
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
      return Text(
        currency.symbol,
        style: TextStyle(fontSize: 18, color: color),
      );
    }
  }

  Future<void> _showCombinedFilterDialog(BuildContext context) async {
    final localizer = S.of(context)!;
    final mintJade = Theme.of(context).extension<MintJadeColors>()!;

    String tempPeriod = _selectedPeriod;
    DateTimeRange? tempRange =
        _selectedRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 10)),
          end: DateTime.now(),
        );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                // Helper to pick a date for start or end inside dialog
                Future<void> pickDate({required bool isStart}) async {
                  final picked = await showGlobalCupertinoDatePicker(
                    context: context,
                    initialDate: isStart ? tempRange!.start : tempRange!.end,
                    minDate: isStart ? DateTime(2000) : tempRange!.start,
                    maxDate: isStart ? tempRange!.end : DateTime.now(),
                  );
                  if (picked != null) {
                    setStateDialog(() {
                      if (isStart) {
                        tempRange = DateTimeRange(
                          start: picked,
                          end: tempRange!.end.isBefore(picked)
                              ? picked
                              : tempRange!.end,
                        );
                      } else {
                        tempRange = DateTimeRange(
                          start: tempRange!.start,
                          end: picked.isBefore(tempRange!.start)
                              ? tempRange!.start
                              : picked,
                        );
                      }
                    });
                  }
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.filter_alt,
                          color: tempPeriod == 'range'
                              ? Colors.purple.shade700
                              : Colors.blue.shade700,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          localizer.filter,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tempPeriod == 'range'
                                    ? Colors.purple.shade700
                                    : Colors.blue.shade700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Always show filter options
                    Material(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          _ModernFilterTile(
                            icon: Icons.today,
                            color: Colors.blue.shade700,
                            label: localizer.daily,
                            selected: tempPeriod == 'daily',
                            onTap: () =>
                                setStateDialog(() => tempPeriod = 'daily'),
                          ),
                          _ModernFilterTile(
                            icon: Icons.calendar_month,
                            color: Colors.green.shade700,
                            label: localizer.monthly,
                            selected: tempPeriod == 'monthly',
                            onTap: () =>
                                setStateDialog(() => tempPeriod = 'monthly'),
                          ),
                          _ModernFilterTile(
                            icon: Icons.filter_alt,
                            color: Colors.purple.shade700,
                            label: localizer.filterByRange,
                            selected: tempPeriod == 'range',
                            onTap: () =>
                                setStateDialog(() => tempPeriod = 'range'),
                          ),
                        ],
                      ),
                    ),

                    // Show date pickers only if 'range' selected
                    if (tempPeriod == 'range') ...[
                      const SizedBox(height: 20),
                      _RangeDateTile(
                        icon: Icons.calendar_today,
                        color: Colors.blue.shade700,
                        label: localizer.startDate,
                        date: tempRange!.start,
                        onTap: () => pickDate(isStart: true),
                      ),
                      _RangeDateTile(
                        icon: Icons.event,
                        color: Colors.green.shade700,
                        label: localizer.endDate,
                        date: tempRange!.end,
                        onTap: () => pickDate(isStart: false),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedRange != null)
                        OutlinedButton(
                          onPressed: () {
                            setStateDialog(() {
                              tempRange = null;
                              tempPeriod = 'monthly';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.purple.shade700,
                            side: BorderSide(color: Colors.purple.shade700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(localizer.clearFilter),
                        ),
                    ],

                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Text(localizer.cancel),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pop({'period': tempPeriod, 'range': tempRange});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mintJade.buttonColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            elevation: 2,
                          ),
                          child: Text(localizer.done),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    ).then((result) {
      if (result == null) return;
      final selectedPeriod = result['period'] as String?;
      final selectedRange = result['range'] as DateTimeRange?;

      if (selectedPeriod != null) {
        setState(() {
          _selectedPeriod = selectedPeriod;
          if (selectedPeriod == 'range' && selectedRange != null) {
            _selectedRange = selectedRange;
            _selectedMonth = DateTime.now();
          } else {
            _selectedRange = null;
            _selectedMonth = DateTime.now();
          }
        });
      }
    });
  }

  Widget _buildCategoryChip(BuildContext context, String category) {
    final isSelected = _selectedCategory == category.toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          category[0].toUpperCase() + category.substring(1),
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedCategory = category.toLowerCase();
          });
        },
        selectedColor: Colors.blue.shade100,
        backgroundColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;
    final transactionBox = Hive.box('transactions');
    final categoryBox = Hive.box<Category>('categories');
    final mintJade = Theme.of(context).extension<MintJadeColors>()!;

    return Scaffold(
      body: AppBackground(
        child: ValueListenableBuilder(
          valueListenable: categoryBox.listenable(),
          builder: (context, Box<Category> categoryBox, _) {
            final currentCategories = categoryBox.values
                .map((c) => c.name.toLowerCase())
                .where((name) => name != 'income')
                .toList();

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
                      if (_selectedPeriod == 'range' &&
                          _selectedRange != null) {
                        return !t.date.isBefore(_selectedRange!.start) &&
                            !t.date.isAfter(_selectedRange!.end);
                      }
                      if (_selectedPeriod == 'daily') {
                        return t.date.year == _selectedMonth.year &&
                            t.date.month == _selectedMonth.month &&
                            t.date.day == _selectedMonth.day;
                      } else {
                        return t.date.year == _selectedMonth.year &&
                            t.date.month == _selectedMonth.month;
                      }
                    })
                    .toList();

                final usedCategoryNames = allTransactions
                    .map((t) => t.category.toLowerCase())
                    .toSet();

                final filteredTransactions =
                    allTransactions
                        .where(
                          (t) =>
                              _selectedCategory == 'all' ||
                              t.category.toLowerCase() == _selectedCategory,
                        )
                        .toList()
                      ..sort((a, b) => b.date.compareTo(a.date));

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
                                              if (snapshot.connectionState ==
                                                      ConnectionState.done &&
                                                  snapshot.hasData) {
                                                return snapshot.data!;
                                              }
                                              return const SizedBox(
                                                width: 16,
                                                height: 16,
                                              );
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
                                              if (snapshot.connectionState ==
                                                      ConnectionState.done &&
                                                  snapshot.hasData) {
                                                return snapshot.data!;
                                              }
                                              return const SizedBox(
                                                width: 16,
                                                height: 16,
                                              );
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child:
                          _selectedPeriod == 'range' && _selectedRange != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.filter_alt,
                                  color: Colors.purple.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${DateFormat.yMMMd().format(_selectedRange!.start)} - ${DateFormat.yMMMd().format(_selectedRange!.end)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // OutlinedButton(
                                //   onPressed: () {
                                //     setState(() {
                                //       _selectedRange = null;
                                //       _selectedPeriod = 'monthly';
                                //       _selectedMonth = DateTime.now();
                                //     });
                                //   },
                                //   style: OutlinedButton.styleFrom(
                                //     foregroundColor: Colors.purple.shade700,
                                //     side: BorderSide(
                                //       color: Colors.purple.shade700,
                                //     ),
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(24),
                                //     ),
                                //     padding: const EdgeInsets.symmetric(
                                //       horizontal: 14,
                                //       vertical: 0,
                                //     ),
                                //     minimumSize: const Size(0, 36),
                                //   ),
                                //   child: Text(S.of(context)!.clearFilter),
                                // ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    Icons.filter_alt,
                                    color: Colors.blue.shade700,
                                    size: 28,
                                  ),
                                  tooltip: S.of(context)!.filter,
                                  onPressed: () =>
                                      _showCombinedFilterDialog(context),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios),
                                  onPressed: _previousPeriod,
                                ),
                                Text(
                                  _selectedPeriod == 'daily'
                                      ? DateFormat.yMMMMd().format(
                                          _selectedMonth,
                                        )
                                      : DateFormat.yMMM().format(
                                          _selectedMonth,
                                        ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios),
                                      onPressed: _nextPeriod,
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.filter_alt,
                                        // color: Colors.blue.shade700,
                                        size: 28,
                                      ),
                                      tooltip: S.of(context)!.filter,
                                      onPressed: () =>
                                          _showCombinedFilterDialog(context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      child: SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildCategoryChip(context, 'all'),
                            ...categoryBox.values
                                .where(
                                  (category) => usedCategoryNames.contains(
                                    category.name.toLowerCase(),
                                  ),
                                )
                                .map(
                                  (category) => _buildCategoryChip(
                                    context,
                                    category.name,
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: filteredTransactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FutureBuilder<Widget>(
                                    future: buildCurrencySymbolWidget(
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.hasData) {
                                        return SizedBox(
                                          width: 140,
                                          height: 140,
                                          child: Center(
                                            child: Opacity(
                                              opacity: 0.4,
                                              child: Transform.scale(
                                                scale:
                                                    5, // 18*16=288, close to 300
                                                child: snapshot.data!,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return SizedBox(width: 140, height: 140);
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
                                final amountColor = isIncome
                                    ? Colors.green
                                    : Colors.red;

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
                                                  cat.name ==
                                                  transaction.category,
                                              orElse: () => Category(
                                                name: transaction.category,
                                                icon: 'category',
                                              ),
                                            ),
                                          ),
                                          color: mintJade.unselectedIconColor,
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
                                            transaction.amount.toStringAsFixed(
                                              2,
                                            ),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: amountColor,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          FutureBuilder<Widget>(
                                            future: buildCurrencySymbolWidget(
                                              amountColor,
                                            ),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                      ConnectionState.done &&
                                                  snapshot.hasData) {
                                                return snapshot.data!;
                                              }
                                              return const SizedBox(
                                                width: 16,
                                                height: 16,
                                              );
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
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
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

// Modern filter tile widget for the filter dialog
class _ModernFilterTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModernFilterTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBgColor = isDark
        ? color.withOpacity(0.22)
        : color.withOpacity(0.12);
    final unselectedBgColor = isDark
        ? Colors.grey.shade900
        : Colors.grey.shade100;
    final selectedTextColor = isDark ? Colors.white : color;
    final unselectedTextColor = isDark ? Colors.white70 : Colors.grey.shade900;
    final selectedBorderColor = isDark ? color.withOpacity(0.7) : color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: selected ? selectedBgColor : unselectedBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? selectedBorderColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? selectedTextColor : unselectedTextColor,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? selectedTextColor : unselectedTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: selected
            ? Icon(Icons.check_circle, color: selectedTextColor)
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// Add this widget at the end of the file:
class _RangeDateTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _RangeDateTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.18) : color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.7 : 1),
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormat.yMMMd().format(date),
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey.shade900,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.edit_calendar, color: color),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
