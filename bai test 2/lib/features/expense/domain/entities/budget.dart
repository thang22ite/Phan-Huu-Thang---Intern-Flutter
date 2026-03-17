import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String category;
  final double amount;
  final String monthYear; // VD: '03-2026'

  const Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.monthYear,
  });

  @override
  List<Object?> get props => [id, category, amount, monthYear];
}
