import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_state.dart';
import '../bloc/expense_event.dart';
import '../widgets/glass_expense_card.dart';
import '../widgets/expense_shimmer_loading.dart';
import 'add_expense_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  String _filterType = 'all'; // 'all', 'income', 'expense'
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(LoadExpenses());
  }

  List<Expense> _getFilteredExpenses(List<Expense> expenses) {
    return expenses.where((expense) {
      // 1. Lọc theo chữ
      if (_searchQuery.isNotEmpty && !expense.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      // 2. Lọc theo loại
      if (_filterType != 'all' && expense.type != _filterType) {
        return false;
      }
      // 3. Lọc theo ngày
      if (_startDate != null && expense.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && expense.date.isAfter(_endDate!.add(const Duration(days: 1)))) {
        return false;
      }
      return true;
    }).toList();
  }

  // Mở Date Range Picker
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: _startDate != null && _endDate != null 
          ? DateTimeRange(start: _startDate!, end: _endDate!) 
          : null,
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

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C), // Nền tối sâu tạo chiều không gian
      body: Stack(
        children: [
          // Background "Anti Gravity" với các khối cầu màu sắc mờ ảo
          Positioned(
            top: -50,
            left: -50,
            child: _buildBlurSphere(Colors.purpleAccent, 250),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: _buildBlurSphere(Colors.blueAccent, 300),
          ),
          Positioned(
            top: 300,
            left: 100,
            child: _buildBlurSphere(Colors.pinkAccent, 150),
          ),

          // Lớp Filter bao phủ làm blur tất cả các khối cầu phía sau
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.transparent),
          ),

          // Foreground Content
          SafeArea(
            child: BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoading) {
                  return Column(
                    children: [
                      const SizedBox(height: 100), // Thụt xuống tương đương vị trí Header
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: 5, // Hiển thị 5 khung shimmer
                          itemBuilder: (context, index) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 20.0),
                              child: ExpenseShimmerLoading(),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else if (state is ExpenseLoaded) {
                  final filteredExpenses = _getFilteredExpenses(state.expenses);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tổng cân bằng',
                              style: TextStyle(color: Colors.white70, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${NumberFormat('#,###').format(state.totalBalance)} VNĐ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Search & Filter Box
                            _buildSearchAndFilter(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: filteredExpenses.isEmpty
                           ? const Center(child: Text("Không có giao dịch nào phù hợp.", style: TextStyle(color: Colors.white70)))
                           : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: filteredExpenses.length,
                          itemBuilder: (context, index) {
                            final expense = filteredExpenses[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Dismissible(
                                key: Key(expense.id),
                                background: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 30),
                                ),
                                secondaryBackground: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white, size: 30),
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction == DismissDirection.endToStart) {
                                    // Xóa
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: const Color(0xFF2C2C3E),
                                          title: const Text("Xác nhận xóa", style: TextStyle(color: Colors.white)),
                                          content: const Text("Bạn có chắc chắn muốn xóa giao dịch này không?", style: TextStyle(color: Colors.white70)),
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text("Hủy", style: TextStyle(color: Colors.white54))),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text("Xóa", style: TextStyle(color: Colors.redAccent)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else if (direction == DismissDirection.startToEnd) {
                                    // Cập nhật - Điều hướng tới trang Add/Edit
                                    // Tạm thời Disable việc trượt bay mất (Dismiss) mà chỉ thực hiện action
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AddExpensePage(expenseToEdit: expense)),
                                    );
                                    return false; // Không xóa khỏi UI
                                  }
                                  return false;
                                },
                                onDismissed: (direction) {
                                  if (direction == DismissDirection.endToStart) {
                                    context.read<ExpenseBloc>().add(DeleteExpenseEvent(expense.id));
                                  }
                                },
                                child: GlassExpenseCard(expense: expense),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else if (state is ExpenseError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                          const SizedBox(height: 16),
                          Text(
                            "Lỗi: ${state.message}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => context.read<ExpenseBloc>().add(LoadExpenses()),
                            child: const Text("Thử lại"),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const Center(child: Text("Không có dữ liệu", style: TextStyle(color: Colors.white)));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        // Thanh tìm kiếm
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm giao dịch...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Bộ lọc Loại và Ngày
        Row(
          children: [
            // Dropdown Loại
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterType,
                        dropdownColor: const Color(0xFF2C2C3E),
                        icon: const Icon(Icons.filter_list, color: Colors.white70, size: 18),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        onChanged: (String? newValue) {
                          setState(() => _filterType = newValue!);
                        },
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text("Tất cả")),
                          DropdownMenuItem(value: 'income', child: Text("Thu nhập")),
                          DropdownMenuItem(value: 'expense', child: Text("Chi phí")),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Nút chọn Khoảng Ngày
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () => _selectDateRange(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _startDate != null ? Colors.deepPurpleAccent.withOpacity(0.4) : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.date_range, color: Colors.white70, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _startDate != null 
                              ? "${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}"
                              : "Thời gian",
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_startDate != null) ...[
                            const Spacer(),
                            GestureDetector(
                                onTap: () => setState(() { _startDate = null; _endDate = null; }),
                                child: const Icon(Icons.close, color: Colors.white70, size: 16),
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
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
