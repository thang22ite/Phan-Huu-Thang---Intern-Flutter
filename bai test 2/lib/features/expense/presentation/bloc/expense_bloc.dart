import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/update_expense.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpenses getExpenses;
  final AddExpense addExpense;
  final UpdateExpense updateExpense;
  final DeleteExpense deleteExpense;

  ExpenseBloc({
    required this.getExpenses,
    required this.addExpense,
    required this.updateExpense,
    required this.deleteExpense,
  }) : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      final expenses = await getExpenses();
      
      // 1. Kiểm tra và tạo Giao dịch lặp lại (Recurring Logic)
      bool hasNewRecurring = await _processRecurringExpenses(expenses);

      // Nếu có giao dịch mới được sinh ra, ta fetch lại list một lần nữa để UI cập nhật
      final finalExpenses = hasNewRecurring ? await getExpenses() : expenses;

      // 2. Calculate total balance: Income adds, Expense subtracts
      final totalBalance = finalExpenses.fold(0.0, (sum, item) {
        if (item.type == 'income') return sum + item.amount;
        return sum - item.amount;
      });
      emit(ExpenseLoaded(finalExpenses, totalBalance));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<bool> _processRecurringExpenses(List<Expense> currentExpenses) async {
    bool generatedNew = false;
    final now = DateTime.now();

    for (var expense in currentExpenses) {
      if (!expense.isRecurring || expense.recurrenceInterval == 'none') continue;

      // Tính khoảng thời gian đã qua kể từ lần giao dịch (hoặc lần lặp) gần nhất
      final difference = now.difference(expense.date);
      bool shouldCreateNew = false;
      DateTime nextDate = expense.date;

      if (expense.recurrenceInterval == 'daily' && difference.inDays >= 1) {
        shouldCreateNew = true;
        nextDate = expense.date.add(const Duration(days: 1));
      } else if (expense.recurrenceInterval == 'weekly' && difference.inDays >= 7) {
        shouldCreateNew = true;
        nextDate = expense.date.add(const Duration(days: 7));
      } else if (expense.recurrenceInterval == 'monthly') {
        // Xấp xỉ 1 tháng là 30 ngày để đơn giản hóa logic kiểm tra
        if (difference.inDays >= 30) {
           shouldCreateNew = true;
           nextDate = DateTime(expense.date.year, expense.date.month + 1, expense.date.day);
        }
      }

      if (shouldCreateNew) {
        // 1. Tạo bản ghi Expense mới cho chu kỳ tiếp theo
        final newExpense = Expense(
          id: const Uuid().v4(),
          title: expense.title, // Giữ nguyên tên
          amount: expense.amount, 
          type: expense.type,
          category: expense.category,
          date: nextDate,
          isRecurring: true, // Bản ghi mới tiếp tục lặp lại
          recurrenceInterval: expense.recurrenceInterval,
        );
        
        // 2. Cập nhật bản ghi CŨ thành không lặp lại nữa, 
        // để tránh sinh trùng lặp vô hạn ở lần check sau.
        final oldExpenseUpdated = Expense(
          id: expense.id,
          title: expense.title,
          amount: expense.amount,
          type: expense.type,
          category: expense.category,
          date: expense.date,
          isRecurring: false, // Tắt cờ lặp lại trên bản ghi cũ
          recurrenceInterval: 'none',
        );

        await updateExpense(oldExpenseUpdated);
        await addExpense(newExpense);
        generatedNew = true;
      }
    }
    return generatedNew;
  }

  Future<void> _onAddExpense(AddExpenseEvent event, Emitter<ExpenseState> emit) async {
    try {
      await addExpense(event.expense);
      add(LoadExpenses()); // Reload list after adding
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onUpdateExpense(UpdateExpenseEvent event, Emitter<ExpenseState> emit) async {
    try {
      await updateExpense(event.expense);
      add(LoadExpenses()); // Reload list after updating
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(DeleteExpenseEvent event, Emitter<ExpenseState> emit) async {
    try {
      await deleteExpense(event.id);
      add(LoadExpenses()); // Reload list after deleting
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}
