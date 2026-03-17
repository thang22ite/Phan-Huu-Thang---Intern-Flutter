import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/budget_model.dart';

abstract class BudgetRemoteDataSource {
  Future<List<BudgetModel>> getBudgets(String monthYear);
  Future<void> saveBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final SupabaseClient client;

  BudgetRemoteDataSourceImpl({required this.client});

  @override
  Future<List<BudgetModel>> getBudgets(String monthYear) async {
    final response = await client
        .from('budgets')
        .select()
        .eq('month_year', monthYear);
    return (response as List).map((json) => BudgetModel.fromJson(json)).toList();
  }

  @override
  Future<void> saveBudget(BudgetModel budget) async {
    final data = budget.toJson();
    // Dùng upsert để nếu có id trùng thì update, chưa có thì insert
    await client.from('budgets').upsert(data, onConflict: 'id');
  }

  @override
  Future<void> deleteBudget(String id) async {
    await client.from('budgets').delete().match({'id': id});
  }
}
