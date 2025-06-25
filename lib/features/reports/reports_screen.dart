import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:jaibee/data/models/trancs.dart';
import 'package:jaibee/l10n/s.dart';
import 'package:jaibee/features/advice/financial_advice_screen.dart'; // Adjust path as needed
import 'package:jaibee/data/models/goal_model.dart';
// import 'package:jaibee/screens/edit_goal_dialog.dart';
import 'package:jaibee/shared/widgets/app_background.dart'; // Import your background widget
import 'package:jaibee/core/theme/mint_jade_theme.dart';
import 'package:jaibee/data/models/category.dart'; // Adjust path as needed
import 'package:jaibee/core/utils/category_utils.dart'; // Add this import
import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:jaibee/data/models/budget.dart'; // Adjust path as needed
import 'package:jaibee/core/utils/currency_utils.dart'; // Adjust path as needed
// import 'package:shared_preferences/shared_preferences.dart'; // For currency symbol
import 'package:jaibee/shared/widgets/global_date_picker.dart';
import 'package:jaibee/features/reports/all_categories_chart_screen.dart'; // Adjust path as needed

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

// Helper class for chart data
class _LineChartData {
  final String label;
  final double value;
  _LineChartData({required this.label, required this.value});
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
    final picked = await showGlobalCupertinoDatePicker(
      context: context,
      initialDate: selectedMonth,
      minDate: DateTime(2020),
      maxDate: DateTime.now(),
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
    final mintJade = Theme.of(context).extension<MintJadeColors>()!;

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

    final sortedDailyEntries = dailyExpenses.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    List<FlSpot> expenseSpots = [];
    List<String> dateLabels = [];
    int index = 0;

    for (final entry in sortedDailyEntries) {
      expenseSpots.add(FlSpot(index.toDouble(), entry.value));
      dateLabels.add(entry.key);
      index++;
    }

    double maxExpense = dailyExpenses.isNotEmpty
        ? dailyExpenses.values.reduce((a, b) => a > b ? a : b)
        : 100;
    double interval = (maxExpense / 4).ceilToDouble();
    double avgExpense = dailyExpenses.isNotEmpty
        ? dailyExpenses.values.reduce((a, b) => a + b) / dailyExpenses.length
        : 0;
    double totalExpense = dailyExpenses.values.fold(0, (a, b) => a + b);

    Map<String, double> monthlyExpenses = {};
    if (!isMonthlyView) {
      for (var txn in filteredTransactions) {
        final monthKey = DateFormat('yyyy-MM').format(txn.date);
        monthlyExpenses.update(
          monthKey,
          (v) => v + txn.amount,
          ifAbsent: () => txn.amount,
        );
      }
    }
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
        backgroundColor: mintJade.buttonColor,
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
                      isMonthlyView
                        ? localizer.dailyExpenses
                        : localizer.monthlyExpenses,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isMonthlyView)
                      _buildLineChart(
                        expenseSpots,
                        dateLabels,
                        interval,
                        maxExpense,
                      )
                    else
                      _buildMonthlyLineChart(monthlyExpenses),
                    const SizedBox(height: 32),
                    Text(
                      localizer.mostSpentCategories,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBarChart(categoryExpenses),
                    const SizedBox(height: 32),
                    // Text(
                    //   localizer.categoryDistribution,
                    //   style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    //     fontWeight: FontWeight.bold,
                    //     color: Theme.of(context).colorScheme.secondary,
                    //   ),
                    // ),
                    // const SizedBox(height: 16),
                    // _buildPieChart(categoryExpenses),
                    // const SizedBox(height: 32),
                    if (goals.isNotEmpty) ...[
                      Text(
                        localizer.yourGoals,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...goals.map(
                        (goal) => _buildGoalProgressCard(goal, index),
                      ),
                      const SizedBox(height: 50),
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
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              localizer.noDataAdvice,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle(S localizer) {
    final mintJade = Theme.of(context).extension<MintJadeColors>()!;
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
          color: mintJade.buttonColor,
          fillColor: mintJade.buttonColor,
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
              FutureBuilder<Widget>(
                future: buildCurrencySymbolWidget(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return snapshot.data!;
                  }
                  return const SizedBox(width: 22, height: 22);
                },
              ),
            ],
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              Text('${localizer.totalSpent}: '),
              Text(total.toStringAsFixed(2)),
              const SizedBox(width: 4),
              FutureBuilder<Widget>(
                future: buildCurrencySymbolWidget(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return snapshot.data!;
                  }
                  return const SizedBox(width: 22, height: 22);
                },
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
    // final localizer = S.of(context)!;

    // Prepare data for Syncfusion (x: date, y: amount)
    final List<_LineChartData> chartData = List.generate(
      spots.length,
      (i) => _LineChartData(label: labels[i], value: spots[i].y),
    );

    if (chartData.isEmpty) {
      return const Center(child: Text("No data to display."));
    }
    return Container(
      height: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: SfCartesianChart(
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          majorGridLines: const MajorGridLines(width: 0), // No vertical grid lines
        ),
        primaryYAxis: NumericAxis(
          labelStyle: const TextStyle(fontSize: 10),
          axisLine: const AxisLine(width: 0),
          majorGridLines: const MajorGridLines(width: 0), // No horizontal grid lines
          minimum: 0,
          maximum: maxY + interval * 2,
          interval: interval,
        ),
        series: <CartesianSeries<_LineChartData, String>>[
          LineSeries<_LineChartData, String>(
            dataSource: chartData,
            xValueMapper: (data, _) =>
                DateFormat('MM/dd').format(DateTime.parse(data.label)),
            yValueMapper: (data, _) => data.value,
            color: Colors.redAccent,
            width: 4,
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 8,
              width: 8,
              shape: DataMarkerType.circle,
            ),
            dataLabelSettings: const DataLabelSettings(isVisible: false),
            enableTooltip: true,
          ),
          AreaSeries<_LineChartData, String>(
            dataSource: chartData,
            xValueMapper: (data, _) =>
                DateFormat('MM/dd').format(DateTime.parse(data.label)),
            yValueMapper: (data, _) => data.value,
            gradient: LinearGradient(
              colors: [
                Colors.redAccent.withOpacity(0.3),
                Colors.orange.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderColor: Colors.transparent,
            borderWidth: 0,
            opacity: 0.7,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyLineChart(Map<String, double> monthlyExpenses) {
    // Prepare data for Syncfusion (x: month, y: amount)
    final List<_LineChartData> chartData = monthlyExpenses.entries.map((entry) {
      return _LineChartData(label: entry.key, value: entry.value);
    }).toList();

    if (chartData.isEmpty) {
      return const Center(child: Text("No data to display."));
    }

    final double maxExpense = chartData
        .map((e) => e.value)
        .fold(0.0, (a, b) => a > b ? a : b);
    final double interval = (maxExpense / 4).ceilToDouble();

    return Container(
      height: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: SfCartesianChart(
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          majorGridLines: const MajorGridLines(width: 0), // No vertical grid lines
        ),
        primaryYAxis: NumericAxis(
          labelStyle: const TextStyle(fontSize: 10),
          axisLine: const AxisLine(width: 0),
          majorGridLines: const MajorGridLines(width: 0), // No horizontal grid lines
          minimum: 0,
          maximum: maxExpense + interval * 2,
          interval: interval,
        ),
        series: <CartesianSeries<_LineChartData, String>>[
          LineSeries<_LineChartData, String>(
            dataSource: chartData,
            xValueMapper: (data, _) => data.label,
            yValueMapper: (data, _) => data.value,
            color: Colors.redAccent,
            width: 4,
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 8,
              width: 8,
              shape: DataMarkerType.circle,
            ),
            dataLabelSettings: const DataLabelSettings(isVisible: false),
            enableTooltip: true,
          ),
          AreaSeries<_LineChartData, String>(
            dataSource: chartData,
            xValueMapper: (data, _) => data.label,
            yValueMapper: (data, _) => data.value,
            gradient: LinearGradient(
              colors: [
                Colors.redAccent.withOpacity(0.3),
                Colors.orange.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderColor: Colors.transparent,
            borderWidth: 0,
            opacity: 0.7,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> categoryExpenses) {
    final localizer = S.of(context)!;
    final categoryBox = Hive.box<Category>('categories');
    final existingCategoryNames = categoryBox.values.map((cat) => cat.name).toSet();

    final sortedCategories = categoryExpenses.entries
        .where((entry) => existingCategoryNames.contains(entry.key))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = sortedCategories.take(4).toList();

    if (topCategories.isEmpty) {
      return const Center(child: Text("No valid categories to display."));
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AllCategoriesChartScreen(categoryExpenses: categoryExpenses),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 320,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                majorGridLines: const MajorGridLines(width: 0), // No vertical grid lines
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(fontSize: 10),
                axisLine: const AxisLine(width: 0),
                majorGridLines: const MajorGridLines(width: 0), // No horizontal grid lines
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                ColumnSeries<MapEntry<String, double>, String>(
                  dataSource: topCategories,
                  xValueMapper: (entry, _) => getLocalizedCategory(entry.key, localizer),
                  yValueMapper: (entry, _) => entry.value,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  pointColorMapper: (entry, idx) => Colors.primaries[idx % Colors.primaries.length],
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  gradient: LinearGradient(
                    colors: [Colors.redAccent, Colors.orange],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              localizer.clickToSeeAllCategoriesInfo,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildPieChart(Map<String, double> categoryExpenses) {
  //   final localizer = S.of(context)!;
  //   final categoryBox = Hive.box<Category>('categories');
  //   final existingCategoryNames = categoryBox.values
  //       .map((cat) => cat.name)
  //       .toSet();

  //   final sortedEntries =
  //       categoryExpenses.entries
  //           .where((entry) => existingCategoryNames.contains(entry.key))
  //           .toList()
  //         ..sort((a, b) => b.value.compareTo(a.value));

  //   final topEntries = sortedEntries.take(5).toList();
  //   final total = topEntries.fold(0.0, (sum, item) => sum + item.value);

  //   if (topEntries.isEmpty) {
  //     return const Center(child: Text("No valid categories to display."));
  //   }

  //   return Container(
  //     height: 320,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).cardColor,
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
  //     ),
  //     child: SfCircularChart(
  //       legend: Legend(
  //         isVisible: true,
  //         overflowMode: LegendItemOverflowMode.wrap,
  //         position: LegendPosition.bottom,
  //         textStyle: const TextStyle(fontSize: 12),
  //       ),
  //       tooltipBehavior: TooltipBehavior(enable: true),
  //       series: <PieSeries<MapEntry<String, double>, String>>[
  //         PieSeries<MapEntry<String, double>, String>(
  //           dataSource: topEntries,
  //           xValueMapper: (entry, _) =>
  //               getLocalizedCategory(entry.key, localizer),
  //           yValueMapper: (entry, _) => entry.value,
  //           dataLabelMapper: (entry, _) =>
  //               '${getLocalizedCategory(entry.key, localizer)}\n${((entry.value / total) * 100).toStringAsFixed(1)}%',
  //           dataLabelSettings: const DataLabelSettings(
  //             isVisible: true,
  //             labelPosition: ChartDataLabelPosition.outside,
  //             connectorLineSettings: ConnectorLineSettings(
  //               type: ConnectorType.curve,
  //             ),
  //             textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
  //           ),
  //           pointColorMapper: (entry, idx) =>
  //               Colors.primaries[idx % Colors.primaries.length],
  //           explode: true,
  //           explodeIndex: 0,
  //           radius: '90%',
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildGoalProgressCard(Goal goal, int index) {
    final localizer = S.of(context)!;
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
          '${localizer.pastDue}: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}';
    } else {
      dateStatusText =
          '${localizer.target}: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year} • $daysLeft ${localizer.daysLeft}';
    }

    return InkWell(
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
                  '${localizer.saved}: ${goal.savedAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  '${localizer.goal}: ${goal.targetAmount.toStringAsFixed(2)}',
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
