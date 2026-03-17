import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getBudgets(String monthYear);
  Future<void> saveBudget(Budget budget); // Add or Update
  Future<void> deleteBudget(String id);
}
