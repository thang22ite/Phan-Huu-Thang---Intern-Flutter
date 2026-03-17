import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<void> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final SupabaseClient client;

  ExpenseRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final response = await client.from('expenses').select();
      print('Supabase query success: $response');
      return (response as List).map((json) => ExpenseModel.fromJson(json)).toList();
    } catch (e) {
      print('Supabase query error: $e');
      rethrow;
    }
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final data = expense.toJson();
      print('Supabase insert attempt: $data');
      await client.from('expenses').insert(data);
      print('Supabase insert success');
    } catch (e) {
      print('Supabase insert error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      final data = expense.toJson();
      print('Supabase update attempt: $data');
      await client.from('expenses').update(data).match({'id': expense.id});
      print('Supabase update success');
    } catch (e) {
      print('Supabase update error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      print('Supabase delete attempt: $id');
      await client.from('expenses').delete().match({'id': id});
      print('Supabase delete success');
    } catch (e) {
      print('Supabase delete error: $e');
      rethrow;
    }
  }
}
