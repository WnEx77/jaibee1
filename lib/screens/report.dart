import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:jaibee1/models/trancs.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/screens/FinancialAdviceScreen.dart'; // Adjust path as needed
import 'package:jaibee1/models/goal_model.dart';
// import 'package:jaibee1/screens/edit_goal_dialog.dart';
import 'package:jaibee1/widgets/app_background.dart'; // Import your background widget
import 'package:jaibee1/providers/mint_jade_theme.dart';
import 'package:jaibee1/models/category.dart'; // Adjust path as needed

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late List<Transaction> allTransactions;
  late List<Transaction> filteredTransactions;
  DateTime selectedMonth = DateTime.now();
  bool isMonthlyView = true;

  late List<Goal> goals;

  @override
  void initState() {
    super.initState();
    final transactionBox = Hive.box('transactions');
    allTransactions = transactionBox.values.toList().cast<Transaction>();

    final goalBox = Hive.box<Goal>('goals'); // ✅ safe if already open
    goals = goalBox.values.toList().cast<Goal>();

    _filterTransactions();
  }

  void _filterTransactions() {
    if (isMonthlyView) {
      filteredTransactions = allTransactions.where((txn) {
        return !txn.isIncome &&
            txn.date.year == selectedMonth.year &&
            txn.date.month == selectedMonth.month;
      }).toList();
    } else {
      filteredTransactions = allTransactions
          .where((txn) => !txn.isIncome)
          .toList();
    }
    setState(() {});
  }

  void _pickMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Month',
      fieldHintText: 'MM/YYYY',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(picked.year, picked.month);
        _filterTransactions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;
    final mintTheme = Theme.of(context).extension<MintJadeColors>()!;

    Map<String, double> dailyExpenses = {};
    Map<String, double> categoryExpenses = {};

    for (var txn in filteredTransactions) {
      String dateKey = DateFormat('yyyy-MM-dd').format(txn.date);
      dailyExpenses.update(
        dateKey,
        (v) => v + txn.amount,
        ifAbsent: () => txn.amount,
      );
      final cat = txn.category;
      categoryExpenses.update(
        cat,
        (v) => v + txn.amount,
        ifAbsent: () => txn.amount,
      );
    }

    List<FlSpot> expenseSpots = [];
    List<String> dateLabels = [];
    int index = 0;

    dailyExpenses.forEach((date, amount) {
      expenseSpots.add(FlSpot(index.toDouble(), amount));
      dateLabels.add(date);
      index++;
    });

    double maxExpense = dailyExpenses.isNotEmpty
        ? dailyExpenses.values.reduce((a, b) => a > b ? a : b)
        : 100;
    double interval = (maxExpense / 4).ceilToDouble();
    double avgExpense = dailyExpenses.isNotEmpty
        ? dailyExpenses.values.reduce((a, b) => a + b) / dailyExpenses.length
        : 0;
    double totalExpense = dailyExpenses.values.fold(0, (a, b) => a + b);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(localizer.reportTitle),
      //   centerTitle: true,
      //   backgroundColor: const Color.fromARGB(255, 130, 148, 179),
      //   foregroundColor: Colors.white,
      //   elevation: 1,
      // ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const FinancialAdviceScreen(),
            ),
          );
        },
        label: Text(localizer.getAdvice),
        icon: const Icon(Icons.lightbulb),
        backgroundColor: mintTheme.buttonColor,
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            _filterTransactions();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildViewToggle(localizer),
                const SizedBox(height: 16),
                if (isMonthlyView) _buildMonthPicker(localizer),
                const SizedBox(height: 24),
                if (filteredTransactions.isEmpty) ...[
                  _buildEmptyState(localizer),
                ] else ...[
                  _buildSummaryCard(localizer, avgExpense, totalExpense),
                  const SizedBox(height: 24),
                  if (dailyExpenses.isNotEmpty) ...[
                    Text(
                      localizer.dailyExpenses,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLineChart(
                      expenseSpots,
                      dateLabels,
                      interval,
                      maxExpense,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      localizer.selectCategory,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBarChart(categoryExpenses),
                    const SizedBox(height: 32),
                    _buildPieChart(categoryExpenses),
                    if (goals.isNotEmpty) ...[
                      Text(
                        localizer.yourGoals,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...goals
                          .map((goal) => _buildGoalProgressCard(goal, index))
                          .toList(),
                    ],
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(S localizer) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_chart_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
            ),
            Text(
              localizer.noDataMonth,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              localizer.noDataAdvice,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle(S localizer) {
    final mintTheme = Theme.of(context).extension<MintJadeColors>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ToggleButtons(
          isSelected: [isMonthlyView, !isMonthlyView],
          onPressed: (index) {
            setState(() {
              isMonthlyView = index == 0;
              _filterTransactions();
            });
          },
          borderRadius: BorderRadius.circular(12),
          selectedColor: Colors.white,
          color: mintTheme.buttonColor,
          fillColor: mintTheme.buttonColor,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(localizer.monthly),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(localizer.allTime),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthPicker(S localizer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850] : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark) const BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left),
            onPressed: () {
              setState(() {
                selectedMonth = DateTime(
                  selectedMonth.year,
                  selectedMonth.month - 1,
                );
                _filterTransactions();
              });
            },
          ),
          GestureDetector(
            onTap: () => _pickMonth(context),
            child: Text(
              DateFormat('MMMM yyyy').format(selectedMonth),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right),
            onPressed: () {
              final now = DateTime.now();
              final nextMonth = DateTime(
                selectedMonth.year,
                selectedMonth.month + 1,
              );
              if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
                setState(() {
                  selectedMonth = nextMonth;
                  _filterTransactions();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(S localizer, double avg, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${localizer.averageDaily}: '),
              Text(avg.toStringAsFixed(2)),
              const SizedBox(width: 4),
              Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/images/Saudi_Riyal_Symbol_DarkMode.png'
                    : 'assets/images/Saudi_Riyal_Symbol.png',
                width: 16,
                height: 16,
              ),
            ],
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              Text('${localizer.totalSpent}: '),
              Text(total.toStringAsFixed(2)),
              const SizedBox(width: 4),
              Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/images/Saudi_Riyal_Symbol_DarkMode.png'
                    : 'assets/images/Saudi_Riyal_Symbol.png',
                width: 16,
                height: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(
    List<FlSpot> spots,
    List<String> labels,
    double interval,
    double maxY,
  ) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx >= 0 && idx < labels.length) {
                    return Text(
                      DateFormat(
                        'MM/dd',
                      ).format(DateFormat('yyyy-MM-dd').parse(labels[idx])),
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 2),
                      Image.asset(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'assets/images/Saudi_Riyal_Symbol_DarkMode.png'
                            : 'assets/images/Saudi_Riyal_Symbol.png',
                        width: 10,
                        height: 10,
                      ),
                    ],
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.redAccent, Colors.orange],
              ),
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.redAccent.withOpacity(0.3),
                    Colors.orange.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
            ),
          ),
          minY: 0,
          maxY: maxY + interval * 2,
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> categoryExpenses) {
    final categoryBox = Hive.box<Category>('categories');
    final existingCategoryNames = categoryBox.values
        .map((cat) => cat.name)
        .toSet();

    // Filter and sort categories by value
    final sortedCategories =
        categoryExpenses.entries
            .where((entry) => existingCategoryNames.contains(entry.key))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = sortedCategories.take(5).toList();

    if (topCategories.isEmpty) {
      return const Center(child: Text("No valid categories to display."));
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: topCategories.first.value + 10,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < topCategories.length) {
                    return Text(
                      topCategories[index].key,
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 2),
                      Image.asset(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'assets/images/Saudi_Riyal_Symbol_DarkMode.png'
                            : 'assets/images/Saudi_Riyal_Symbol.png',
                        width: 10,
                        height: 10,
                      ),
                    ],
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups: List.generate(topCategories.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: topCategories[i].value,
                  gradient: const LinearGradient(
                    colors: [Colors.redAccent, Colors.orange],
                  ),
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> categoryExpenses) {
    final categoryBox = Hive.box<Category>('categories');
    final existingCategoryNames = categoryBox.values
        .map((cat) => cat.name)
        .toSet();

    final sortedEntries =
        categoryExpenses.entries
            .where((entry) => existingCategoryNames.contains(entry.key))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final topEntries = sortedEntries.take(5).toList();
    final total = topEntries.fold(0.0, (sum, item) => sum + item.value);

    if (topEntries.isEmpty) {
      return const Center(child: Text("No valid categories to display."));
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: PieChart(
        PieChartData(
          sections: topEntries.map((entry) {
            final value = entry.value;
            final percentage = (value / total) * 100;
            return PieChartSectionData(
              value: value,
              title: '${entry.key} (${percentage.toStringAsFixed(1)}%)',
              color:
                  Colors.primaries[categoryExpenses.keys.toList().indexOf(
                        entry.key,
                      ) %
                      Colors.primaries.length],
              radius: 80,
              titleStyle: const TextStyle(fontSize: 12, color: Colors.black),
            );
          }).toList(),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildGoalProgressCard(Goal goal, int index) {
    final progress = goal.targetAmount > 0
        ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    final now = DateTime.now();
    final daysLeft = goal.targetDate.difference(now).inDays;
    final isPastDue = daysLeft < 0;

    Color progressColor;
    if (progress >= 1.0) {
      progressColor = Colors.green;
    } else if (isPastDue) {
      progressColor = Colors.red;
    } else if (daysLeft <= 7) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.blue;
    }

    String dateStatusText;
    if (isPastDue) {
      dateStatusText =
          'Past due: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}';
    } else {
      dateStatusText =
          'Target: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year} • $daysLeft days left';
    }

    return InkWell(
      // onTap: () {
      //   showDialog(
      //     context: context,
      //     builder: (context) => EditGoalDialog(
      //       goal: goal,
      //       index: index,
      //       onUpdate: (updatedGoal, index) {
      //         setState(() {
      //           goals[index] = updatedGoal;
      //         });
      //       },
      //       onDelete: (index) {
      //         setState(() {
      //           goals.removeAt(index);
      //         });
      //       },
      //     ),
      //   );
      // },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              dateStatusText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isPastDue ? Colors.red : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${goal.savedAmount.toStringAsFixed(2)} saved',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'Goal: \$${goal.targetAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
