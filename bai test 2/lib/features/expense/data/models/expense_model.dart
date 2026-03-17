import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.category,
    required super.date,
    super.isRecurring = false,
    super.recurrenceInterval = 'none',
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] ?? 'expense', // Fallback for old data
      category: json['category'],
      date: DateTime.parse(json['date']),
      isRecurring: json['is_recurring'] ?? false,
      recurrenceInterval: json['recurrence_interval'] ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'is_recurring': isRecurring,
      'recurrence_interval': recurrenceInterval,
    };
  }
}
