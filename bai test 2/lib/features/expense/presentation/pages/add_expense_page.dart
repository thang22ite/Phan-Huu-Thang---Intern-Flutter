import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event_state.dart';
import '../bloc/expense_state.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../../../../core/utils/category_utils.dart';
import 'package:uuid/uuid.dart';

class AddExpensePage extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpensePage({super.key, this.expenseToEdit});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  
  bool _isIncome = false; // Toggle between Income and Expense
  late String _selectedCategory;
  late List<String> _currentCategories;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String _recurrenceInterval = 'monthly'; // 'daily', 'weekly', 'monthly'

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final old = widget.expenseToEdit!;
      _titleController.text = old.title;
      _amountController.text = old.amount.toString();
      _isIncome = old.type == 'income';
      _currentCategories = _isIncome ? CategoryUtils.incomeCategories : CategoryUtils.expenseCategories;
      _selectedCategory = old.category;
      _selectedDate = old.date;
      _isRecurring = old.isRecurring;
      _recurrenceInterval = old.recurrenceInterval != 'none' ? old.recurrenceInterval : 'monthly';
    } else {
      _currentCategories = CategoryUtils.expenseCategories;
      _selectedCategory = _currentCategories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onTypeChanged(bool isIncome) {
    setState(() {
      _isIncome = isIncome;
      _currentCategories = isIncome ? CategoryUtils.incomeCategories : CategoryUtils.expenseCategories;
      _selectedCategory = _currentCategories.first; // Reset category selection when switching type
    });
  }

  void _submitExpense() async {
    final title = _titleController.text;
    final amountText = _amountController.text;

    if (title.isEmpty || amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null) return;

    // Kiểm tra ngân sách nếu là Chi phí
    if (!_isIncome) {
      final budgetState = context.read<BudgetBloc>().state;
      final expenseState = context.read<ExpenseBloc>().state;
      final currentMonthYear = DateFormat('MM-yyyy').format(_selectedDate);

      if (budgetState is BudgetLoaded && expenseState is ExpenseLoaded) {
        final budget = budgetState.budgets.cast<dynamic>().firstWhere(
          (b) => b.category == _selectedCategory && b.monthYear == currentMonthYear,
          orElse: () => null,
        );

        if (budget != null) {
          final spentSoFar = expenseState.expenses
              .where((e) => e.type == 'expense' && e.category == _selectedCategory && DateFormat('MM-yyyy').format(e.date) == currentMonthYear)
              .fold(0.0, (sum, e) => sum + e.amount);

          if (spentSoFar + amount > budget.amount) {
            final proceed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF2C2C3E),
                title: const Text("Cảnh báo Ngân sách", style: TextStyle(color: Colors.white)),
                content: Text(
                  "Giao dịch này sẽ khiến bạn vượt ngân sách ${_selectedCategory} (${NumberFormat('#,###').format(budget.amount)} VNĐ). Bạn có muốn tiếp tục không?",
                  style: const TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Tiếp tục", style: TextStyle(color: Colors.tealAccent)),
                  ),
                ],
              ),
            );

            if (proceed != true) return;
          }
        }
      }
    }

    _saveToBloc(title, amount);
  }

  void _saveToBloc(String title, double amount) {
    if (widget.expenseToEdit != null) {
      final updatedExpense = Expense(
        id: widget.expenseToEdit!.id,
        title: title,
        amount: amount,
        type: _isIncome ? 'income' : 'expense',
        category: _selectedCategory,
        date: _selectedDate,
        isRecurring: _isRecurring,
        recurrenceInterval: _isRecurring ? _recurrenceInterval : 'none',
      );
      context.read<ExpenseBloc>().add(UpdateExpenseEvent(updatedExpense));
    } else {
      final expense = Expense(
        id: const Uuid().v4(),
        title: title,
        amount: amount,
        type: _isIncome ? 'income' : 'expense',
        category: _selectedCategory,
        date: _selectedDate,
        isRecurring: _isRecurring,
        recurrenceInterval: _isRecurring ? _recurrenceInterval : 'none',
      );
      context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
    }
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text(widget.expenseToEdit != null ? 'Sửa Giao Dịch' : 'Thêm Giao Dịch', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: 50,
            right: -50,
            child: _buildBlurSphere(Colors.orangeAccent, 200),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildBlurSphere(Colors.greenAccent, 250),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.transparent),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildTypeToggle(),
                  const SizedBox(height: 30),
                  _buildGlassTextField(
                    controller: _titleController,
                    hintText: 'Tiêu đề (VD: Trà sữa)',
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 20),
                  _buildGlassTextField(
                    controller: _amountController,
                    hintText: 'Số tiền',
                    icon: Icons.payments,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildGlassDropdown()),
                      const SizedBox(width: 16),
                      _buildGlassDatePicker(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildRecurringToggle(),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _submitExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Lưu Giao Dịch',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(title: 'Chi phí', isSelected: !_isIncome, onTap: () => _onTypeChanged(false)),
          _buildToggleOption(title: 'Thu nhập', isSelected: _isIncome, onTap: () => _onTypeChanged(true)),
        ],
      ),
    );
  }

  Widget _buildToggleOption({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRecurringToggle() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  const Text('Lặp lại chi phí này?', style: TextStyle(color: Colors.white, fontSize: 16)),
                  Switch(
                    value: _isRecurring,
                    onChanged: (val) => setState(() => _isRecurring = val),
                    activeColor: Colors.tealAccent,
                  ),
                ],
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 10),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _recurrenceInterval,
                    dropdownColor: const Color(0xFF2C2C3E),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    onChanged: (String? newValue) {
                      setState(() {
                        _recurrenceInterval = newValue!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text("Hàng ngày")),
                      DropdownMenuItem(value: 'weekly', child: Text("Hàng tuần")),
                      DropdownMenuItem(value: 'monthly', child: Text("Hàng tháng")),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: Icon(icon, color: Colors.white70),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassDropdown() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              dropdownColor: const Color(0xFF2C2C3E),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
              items: _currentCategories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(CategoryUtils.getIcon(value, isIncome: _isIncome), color: CategoryUtils.getColor(value, isIncome: _isIncome), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassDatePicker() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Colors.deepPurpleAccent,
                  onPrimary: Colors.white,
                  surface: Color(0xFF2C2C3E),
                  onSurface: Colors.white,
                ),
                dialogBackgroundColor: const Color(0xFF1E1E2C),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && picked != _selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
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
