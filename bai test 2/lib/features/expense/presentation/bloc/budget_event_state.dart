import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';

// --- EVENTS ---
abstract class BudgetEvent extends Equatable {
  const BudgetEvent();
  @override
  List<Object> get props => [];
}

class LoadBudgets extends BudgetEvent {
  final String monthYear; // VD: '03-2026'
  const LoadBudgets(this.monthYear);
  @override
  List<Object> get props => [monthYear];
}

class SaveBudgetEvent extends BudgetEvent {
  final Budget budget;
  const SaveBudgetEvent(this.budget);
  @override
  List<Object> get props => [budget];
}

class DeleteBudgetEvent extends BudgetEvent {
  final String id;
  const DeleteBudgetEvent(this.id);
  @override
  List<Object> get props => [id];
}

// --- STATES ---
abstract class BudgetState extends Equatable {
  const BudgetState();
  @override
  List<Object> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<Budget> budgets;
  final String monthYear;
  const BudgetLoaded(this.budgets, this.monthYear);
  @override
  List<Object> get props => [budgets, monthYear];
}

class BudgetError extends BudgetState {
  final String message;
  const BudgetError(this.message);
  @override
  List<Object> get props => [message];
}
