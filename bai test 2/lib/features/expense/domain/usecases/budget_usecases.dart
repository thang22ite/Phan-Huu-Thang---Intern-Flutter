import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class GetBudgets {
  final BudgetRepository repository;
  GetBudgets(this.repository);
  Future<List<Budget>> call(String monthYear) async => await repository.getBudgets(monthYear);
}

class SaveBudget {
  final BudgetRepository repository;
  SaveBudget(this.repository);
  Future<void> call(Budget budget) async => await repository.saveBudget(budget);
}

class DeleteBudget {
  final BudgetRepository repository;
  DeleteBudget(this.repository);
  Future<void> call(String id) async => await repository.deleteBudget(id);
}
