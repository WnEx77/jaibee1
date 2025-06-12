import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:jaibee1/models/trancs.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/screens/FinancialAdviceScreen.dart'; // Adjust path as needed
import 'package:jaibee1/models/goal_model.dart';
import 'package:jaibee1/screens/edit_goal_dialog.dart';

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

    Map<String, double> dailyExpenses = {};
    Map<String, double> categoryExpenses = {};

    for (var txn in filteredTransactions) {
      String dateKey = DateFormat('yyyy-MM-dd').format(txn.date);
      dailyExpenses.update(
        dateKey,
        (v) => v + txn.amount,
        ifAbsent: () => txn.amount,
      );
      final cat = txn.category ?? 'Other';
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
      appBar: AppBar(
        title: Text(localizer.reportTitle),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 130, 148, 179),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
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
        backgroundColor: const Color.fromARGB(255, 130, 148, 179),
      ),
      body: filteredTransactions.isEmpty
          ? _buildEmptyState(localizer)
          : RefreshIndicator(
              onRefresh: () async {
                _filterTransactions();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildViewToggle(localizer),
                    const SizedBox(height: 16),
                    if (isMonthlyView) _buildMonthPicker(localizer),
                    const SizedBox(height: 24),
                    _buildSummaryCard(localizer, avgExpense, totalExpense),
                    const SizedBox(height: 24),
                    if (dailyExpenses.isNotEmpty) ...[
                      Text(
                        localizer.dailyExpenses,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent.shade700,
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
                          color: Colors.redAccent.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBarChart(categoryExpenses),
                      const SizedBox(height: 32),
                      _buildPieChart(categoryExpenses), // Add Pie Chart here
                      if (goals.isNotEmpty) ...[
                        Text(
                          localizer.yourGoals,
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent.shade700,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ...goals
                            .map((goal) => _buildGoalProgressCard(goal, index))
                            .toList(),
                      ],
                    ],
                  ],
                ),
              ),
            ),
      backgroundColor: const Color(0xFFF9FAFB),
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
              color: Colors.redAccent.shade200,
            ),
            const SizedBox(height: 24),
            Text(
              localizer.noDataMonth,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.redAccent.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              localizer.noDataAdvice,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.redAccent.shade200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle(S localizer) {
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
          color: const Color.fromARGB(255, 130, 148, 179),
          fillColor: const Color.fromARGB(255, 130, 148, 179),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${localizer.averageDaily}: \$${avg.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          Text('${localizer.totalSpent}: \$${total.toStringAsFixed(2)}'),
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
        color: Colors.white,
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
                  return Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
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
              color: Colors.grey.withOpacity(0.3),
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
            border: Border.all(color: Colors.black.withOpacity(0.1)),
          ),
          minY: 0,
          maxY: maxY + interval * 2,
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> categoryExpenses) {
    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: sortedCategories.first.value + 10,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < sortedCategories.length) {
                    return Text(
                      sortedCategories[index].key,
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
                  return Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
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
          barGroups: List.generate(sortedCategories.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: sortedCategories[i].value,
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
    final total = categoryExpenses.values.fold(0.0, (a, b) => a + b);
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: PieChart(
        PieChartData(
          sections: categoryExpenses.entries.map((entry) {
            final value = entry.value;
            final percentage = (value / total) * 100;
            return PieChartSectionData(
              value: value, // This should remain a double
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
      dateStatusText = 'Past due: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}';
    } else {
      dateStatusText = 'Target: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year} • $daysLeft days left';
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
          color: Colors.white,
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