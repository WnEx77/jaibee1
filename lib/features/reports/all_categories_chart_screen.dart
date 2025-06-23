import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:jaibee/data/models/category.dart';
import 'package:jaibee/l10n/s.dart';
import 'package:jaibee/core/utils/category_utils.dart';
import 'package:jaibee/shared/widgets/app_background.dart';
import 'package:jaibee/shared/widgets/custom_app_bar.dart';

class AllCategoriesChartScreen extends StatelessWidget {
  final Map<String, double> categoryExpenses;

  const AllCategoriesChartScreen({super.key, required this.categoryExpenses});

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;
    final categoryBox = Hive.box<Category>('categories');
    final existingCategoryNames = categoryBox.values
        .map((cat) => cat.name)
        .toSet();

    final sortedCategories =
        categoryExpenses.entries
            .where((entry) => existingCategoryNames.contains(entry.key))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedCategories.isEmpty) {
      return AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomAppBar(
            title: localizer.allCategories,
            showBackButton: true,
          ),
          body: const Center(child: Text("No valid categories to display.")),
        ),
      );
    }

    // For better readability, show category names as rotated labels and allow horizontal scrolling.
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: localizer.allCategories,
          showBackButton: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width:
                  sortedCategories.length *
                  80.0, // 80px per bar, adjust as needed
              // ...existing code...
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  labelRotation: 45,
                  maximumLabels: 20,
                  majorGridLines: const MajorGridLines(
                    width: 0,
                  ), // <--- No vertical grid lines
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: const TextStyle(fontSize: 10),
                  axisLine: const AxisLine(width: 0),
                  majorGridLines: const MajorGridLines(
                    width: 0,
                  ), // <--- No horizontal grid lines
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  ColumnSeries<MapEntry<String, double>, String>(
                    dataSource: sortedCategories,
                    xValueMapper: (entry, _) =>
                        getLocalizedCategory(entry.key, localizer),
                    yValueMapper: (entry, _) => entry.value,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    pointColorMapper: (entry, idx) =>
                        Colors.primaries[idx % Colors.primaries.length],
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
          ),
        ),
      ),
    );
  }
}
