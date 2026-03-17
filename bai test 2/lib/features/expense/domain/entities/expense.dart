import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final DateTime date;
  final bool isRecurring;
  final String recurrenceInterval; // 'none', 'daily', 'weekly', 'monthly'

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.isRecurring = false,
    this.recurrenceInterval = 'none',
  });

  @override
  List<Object?> get props => [id, title, amount, type, category, date, isRecurring, recurrenceInterval];
}
