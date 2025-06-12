import 'package:hive/hive.dart';
import '../models/budget.dart';

class BudgetService {
  final Box<Budget> _budgetBox = Hive.box<Budget>('budgets');

  List<Budget> getBudgets() {
    return _budgetBox.values.toList();
  }

  Future<void> addBudget(Budget budget) async {
    await _budgetBox.add(budget);
  }

  Future<void> updateBudget(Budget budget, {required double newLimit}) async {
    budget.limit = newLimit; // You'll need to make `limit` mutable
    await budget.save();
  }

  Future<void> deleteBudget(Budget budget) async {
    await budget.delete();
  }
}
