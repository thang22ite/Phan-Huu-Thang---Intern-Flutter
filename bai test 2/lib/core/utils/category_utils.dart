import 'package:flutter/material.dart';

class CategoryUtils {
  // Income Categories
  static const List<String> incomeCategories = [
    'Salary',
    'Bonus',
    'Investment',
    'Others'
  ];

  static const Map<String, IconData> incomeIcons = {
    'Salary': Icons.account_balance_wallet_rounded,
    'Bonus': Icons.card_giftcard_rounded,
    'Investment': Icons.trending_up_rounded,
    'Others': Icons.category_rounded,
  };

  static const Map<String, Color> incomeColors = {
    'Salary': Colors.greenAccent,
    'Bonus': Colors.tealAccent,
    'Investment': Colors.cyanAccent,
    'Others': Colors.grey,
  };

  // Expense Categories
  static const List<String> expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Others',
  ];

  static const Map<String, IconData> expenseIcons = {
    'Food': Icons.restaurant_rounded,
    'Transport': Icons.directions_car_rounded,
    'Shopping': Icons.shopping_bag_rounded,
    'Entertainment': Icons.movie_rounded,
    'Bills': Icons.receipt_long_rounded,
    'Others': Icons.category_rounded,
  };

  static const Map<String, Color> expenseColors = {
    'Food': Colors.orangeAccent,
    'Transport': Colors.lightBlueAccent,
    'Shopping': Colors.pinkAccent,
    'Entertainment': Colors.deepPurpleAccent,
    'Bills': Colors.redAccent,
    'Others': Colors.grey,
  };

  static IconData getIcon(String category, {required bool isIncome}) {
    if (isIncome) return incomeIcons[category] ?? Icons.help_outline_rounded;
    return expenseIcons[category] ?? Icons.help_outline_rounded;
  }

  static Color getColor(String category, {required bool isIncome}) {
    if (isIncome) return incomeColors[category] ?? Colors.grey;
    return expenseColors[category] ?? Colors.grey;
  }

  static IconData getIconForCategory(String category) {
    return expenseIcons[category] ?? Icons.help_outline_rounded;
  }
}
