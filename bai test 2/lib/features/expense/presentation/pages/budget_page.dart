import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event_state.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_state.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/expense.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/category_utils.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late String _currentMonthYear;

  @override
  void initState() {
    super.initState();
    _currentMonthYear = DateFormat('MM-yyyy').format(DateTime.now());
    context.read<BudgetBloc>().add(LoadBudgets(_currentMonthYear));
    // Lưu ý: Đảm bảo ExpenseBloc cũng đã được load ở HomePage rồi
  }

  void _showAddBudgetDialog() {
    String selectedCategory = CategoryUtils.expenseCategories.first;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2C3E),
              title: const Text('Thêm Ngân Sách', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedCategory,
                    dropdownColor: const Color(0xFF1E1E2C),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white),
                    items: CategoryUtils.expenseCategories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      setStateDialog(() => selectedCategory = val!);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Số tiền giới hạn',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.tealAccent),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null) {
                      final newBudget = Budget(
                        id: const Uuid().v4(),
                        category: selectedCategory,
                        amount: amount,
                        monthYear: _currentMonthYear,
                      );
                      context.read<BudgetBloc>().add(SaveBudgetEvent(newBudget));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Lưu', style: TextStyle(color: Colors.tealAccent)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: _buildBlurSphere(Colors.pinkAccent, 250),
          ),
          Positioned(
            bottom: 50,
            right: -80,
            child: _buildBlurSphere(Colors.blueAccent, 300),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.transparent),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ngân Sách \nTháng ${_currentMonthYear.replaceAll('-', '/')}',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: _showAddBudgetDialog,
                        icon: const Icon(Icons.add_circle, color: Colors.tealAccent, size: 36),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: BlocBuilder<BudgetBloc, BudgetState>(
                    builder: (context, budgetState) {
                      if (budgetState is BudgetLoading) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      } else if (budgetState is BudgetLoaded) {
                        final budgets = budgetState.budgets;
                        if (budgets.isEmpty) {
                          return const Center(
                            child: Text(
                              "Chưa có ngân sách nào.\nHãy nhấn [+] để tạo mới.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          );
                        }

                        // Lắng nghe ExpenseBloc để tính toán số tiền thực tế đã chi
                        return BlocBuilder<ExpenseBloc, ExpenseState>(
                          builder: (context, expenseState) {
                            List<Expense> expensesThisMonth = [];
                            if (expenseState is ExpenseLoaded) {
                              expensesThisMonth = expenseState.expenses.where((e) {
                                return e.type == 'expense' && DateFormat('MM-yyyy').format(e.date) == _currentMonthYear;
                              }).toList();
                            }

                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              itemCount: budgets.length,
                              itemBuilder: (context, index) {
                                final budget = budgets[index];
                                
                                // Tính tổng chi tiêu cho category này
                                final spentAmount = expensesThisMonth
                                    .where((e) => e.category == budget.category)
                                    .fold(0.0, (sum, e) => sum + e.amount);

                                return _buildBudgetCard(budget, spentAmount);
                              },
                            );
                          },
                        );
                      }
                      return const Center(child: Text('Lỗi kết nối', style: TextStyle(color: Colors.redAccent)));
                    },
                  ),
                ),
                const SizedBox(height: 80), // Nhường chỗ cho BottomNav
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(Budget budget, double spentAmount) {
    double progress = spentAmount / budget.amount;
    if (progress > 1.0) progress = 1.0;
    
    // Nếu tiêu vượt > 90% thì cảnh báo màu đỏ
    Color progressColor = Colors.tealAccent;
    if (progress >= 0.9) {
      progressColor = Colors.redAccent;
    } else if (progress >= 0.7) {
      progressColor = Colors.orangeAccent;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Dismissible(
        key: Key(budget.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white, size: 30),
        ),
        onDismissed: (direction) {
          context.read<BudgetBloc>().add(DeleteBudgetEvent(budget.id));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(CategoryUtils.getIconForCategory(budget.category), color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            budget.category,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        "${spentAmount.toStringAsFixed(0)} / ${budget.amount.toStringAsFixed(0)} VNĐ",
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar Setup
                  Stack(
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 12,
                        width: MediaQuery.of(context).size.width * 0.8 * progress, // Ước chừng width
                        decoration: BoxDecoration(
                          color: progressColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: progressColor.withOpacity(0.5), blurRadius: 8, spreadRadius: 1),
                          ]
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    progress >= 1.0 ? "Đã vượt quá ngân sách!" : "Còn lại ${(budget.amount - spentAmount).toStringAsFixed(0)} VNĐ",
                    style: TextStyle(
                      color: progress >= 1.0 ? Colors.redAccent : Colors.white54,
                      fontSize: 13,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlurSphere(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.4),
      ),
    );
  }
}
