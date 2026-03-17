import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/budget_usecases.dart';
import 'budget_event_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetBudgets getBudgets;
  final SaveBudget saveBudget;
  final DeleteBudget deleteBudget;

  String _currentMonthYear = '';

  BudgetBloc({
    required this.getBudgets,
    required this.saveBudget,
    required this.deleteBudget,
  }) : super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<SaveBudgetEvent>(_onSaveBudget);
    on<DeleteBudgetEvent>(_onDeleteBudget);
  }

  Future<void> _onLoadBudgets(LoadBudgets event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      _currentMonthYear = event.monthYear;
      final budgets = await getBudgets(event.monthYear);
      emit(BudgetLoaded(budgets, event.monthYear));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onSaveBudget(SaveBudgetEvent event, Emitter<BudgetState> emit) async {
    try {
      await saveBudget(event.budget);
      add(LoadBudgets(_currentMonthYear)); // Load lại list hiện tại
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onDeleteBudget(DeleteBudgetEvent event, Emitter<BudgetState> emit) async {
    try {
      await deleteBudget(event.id);
      add(LoadBudgets(_currentMonthYear)); // Load lại list hiện tại
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }
}
