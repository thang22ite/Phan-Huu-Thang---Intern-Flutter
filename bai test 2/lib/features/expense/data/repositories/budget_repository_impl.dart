import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_remote_data_source.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource remoteDataSource;

  BudgetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Budget>> getBudgets(String monthYear) async {
    return await remoteDataSource.getBudgets(monthYear);
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    final budgetModel = BudgetModel(
      id: budget.id,
      category: budget.category,
      amount: budget.amount,
      monthYear: budget.monthYear,
    );
    await remoteDataSource.saveBudget(budgetModel);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await remoteDataSource.deleteBudget(id);
  }
}
