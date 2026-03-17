import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Expense>> getExpenses() async {
    return await remoteDataSource.getExpenses();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final expenseModel = ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      type: expense.type,
      category: expense.category,
      date: expense.date,
    );
    await remoteDataSource.addExpense(expenseModel);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final expenseModel = ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      type: expense.type,
      category: expense.category,
      date: expense.date,
    );
    await remoteDataSource.updateExpense(expenseModel);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await remoteDataSource.deleteExpense(id);
  }
}
