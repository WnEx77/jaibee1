import 'package:hive/hive.dart';
import 'package:jaibee/data/models/trancs.dart';
import 'package:jaibee/data/models/budget.dart';

class MonthlySummary {
  final double totalIncome;
  final double totalExpenses;
  final Map<String, double> expensesByCategory;
  final double? monthlyLimit;

  MonthlySummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.expensesByCategory,
    required this.monthlyLimit,
  });
}

MonthlySummary getMonthlySummary(
  DateTime month,
  Box transactionsBox, {
  required Box<Budget> budgetsBox,
}) {
  double income = 0.0;
  double expenses = 0.0;
  Map<String, double> categoryTotals = {};

  for (var transaction in transactionsBox.values) {
    if (transaction is Transaction &&
        transaction.date.month == month.month &&
        transaction.date.year == month.year) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expenses += transaction.amount;
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }
  }

  // ✅ استرجاع الحد الشهري مباشرة من budgetBox باستخدام المفتاح '__monthly__'
  final monthlyBudget = budgetsBox.get('__monthly__');
  final monthlyLimit = monthlyBudget?.limit;

  return MonthlySummary(
    totalIncome: income,
    totalExpenses: expenses,
    expensesByCategory: categoryTotals,
    monthlyLimit: monthlyLimit,
  );
}
