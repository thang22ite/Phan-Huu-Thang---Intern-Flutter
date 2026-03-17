import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/expense/data/datasources/expense_remote_data_source.dart';
import 'features/expense/data/repositories/expense_repository_impl.dart';
import 'features/expense/domain/repositories/expense_repository.dart';
import 'features/expense/domain/usecases/add_expense.dart';
import 'features/expense/domain/usecases/delete_expense.dart';
import 'features/expense/domain/usecases/get_expenses.dart';
import 'features/expense/domain/usecases/update_expense.dart';
import 'features/expense/presentation/bloc/expense_bloc.dart';

// BUdget
import 'features/expense/data/datasources/budget_remote_data_source.dart';
import 'features/expense/data/repositories/budget_repository_impl.dart';
import 'features/expense/domain/repositories/budget_repository.dart';
import 'features/expense/domain/usecases/budget_usecases.dart';
import 'features/expense/presentation/bloc/budget_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- BLOCS ---
  sl.registerFactory(() => ExpenseBloc(
        getExpenses: sl(),
        addExpense: sl(),
        updateExpense: sl(),
        deleteExpense: sl(),
      ));

  sl.registerFactory(() => BudgetBloc(
        getBudgets: sl(),
        saveBudget: sl(),
        deleteBudget: sl(),
      ));

  // --- USE CASES ---
  // Expense
  sl.registerLazySingleton(() => GetExpenses(sl()));
  sl.registerLazySingleton(() => AddExpense(sl()));
  sl.registerLazySingleton(() => UpdateExpense(sl()));
  sl.registerLazySingleton(() => DeleteExpense(sl()));

  // Budget
  sl.registerLazySingleton(() => GetBudgets(sl()));
  sl.registerLazySingleton(() => SaveBudget(sl()));
  sl.registerLazySingleton(() => DeleteBudget(sl()));

  // --- REPOSITORY ---
  // Expense
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(remoteDataSource: sl()),
  );

  // Budget
  sl.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(remoteDataSource: sl()),
  );

  // --- DATA SOURCES ---
  // Expense
  sl.registerLazySingleton<ExpenseRemoteDataSource>(
    () => ExpenseRemoteDataSourceImpl(client: sl()),
  );

  // Budget
  sl.registerLazySingleton<BudgetRemoteDataSource>(
    () => BudgetRemoteDataSourceImpl(client: sl()),
  );

  // --- EXTERNAL ---
  sl.registerLazySingleton(() => Supabase.instance.client);
}
