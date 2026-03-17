import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_state.dart';
import '../../../../core/utils/category_utils.dart';
import '../../../../core/utils/export_service.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _showIncome = false; // Toggle between seeing Income breakdown or Expense breakdown
  String _timeFilter = 'month'; // 'day', 'month', 'year'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: Stack(
        children: [
          // Background "Anti Gravity"
          Positioned(
            top: -50,
            right: -50,
            child: _buildBlurSphere(Colors.deepOrangeAccent, 250),
          ),
          Positioned(
            bottom: 50,
            left: -80,
            child: _buildBlurSphere(Colors.tealAccent, 300),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.transparent),
          ),

          SafeArea(
            child: BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                } else if (state is ExpenseLoaded) {
                  final expenseData = _calculateCategoryData(state.expenses, isIncome: _showIncome);
                  final detailedExpenses = _filterExpenses(state.expenses, isIncome: _showIncome);
                  
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Báo cáo chi tiết',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  ExportService.exportExpensesToCSV(state.expenses);
                                },
                                icon: const Icon(Icons.cloud_download, color: Colors.tealAccent, size: 28),
                                tooltip: "Xuất file CSV",
                              )
                            ],
                          ),
                        ),
                        _buildTimeFilterToggle(),
                        
                        _buildTypeToggle(),
                        const SizedBox(height: 30),

                        // Bar Chart (Always shows income vs expense overall)
                        if (state.expenses.isNotEmpty)
                          SizedBox(
                            height: 200,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: _buildTimeBarChart(state.expenses),
                            ),
                          )
                        else
                          const SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                "Chưa có dữ liệu giao dịch.",
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ),
                          ),
                        const SizedBox(height: 30),

                        if (expenseData.isEmpty)
                          SizedBox(
                            height: 300,
                            child: Center(
                              child: Text(
                                _showIncome ? "Chưa có thu nhập nào." : "Chưa có khoản chi nào.",
                                style: const TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              // Pie Chart (Category Distribution)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Cơ cấu danh mục",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 250,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 60,
                                    sections: _buildPieChartSections(expenseData),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Chi tiết danh mục",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                itemCount: expenseData.length,
                                itemBuilder: (context, index) {
                                  String category = expenseData.keys.elementAt(index);
                                  double amount = expenseData[category]!;
                                  
                                  // Lọc các item thuộc category này
                                  final itemsInCategory = detailedExpenses.where((e) => e.category == category).toList();

                                  return _buildStatRowWithDetails(category, amount, itemsInCategory);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 80), // Nav Bar space
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilterToggle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            title: 'Ngày',
            isSelected: _timeFilter == 'day',
            onTap: () => setState(() => _timeFilter = 'day'),
            radius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          _buildToggleOption(
            title: 'Tháng',
            isSelected: _timeFilter == 'month',
            onTap: () => setState(() => _timeFilter = 'month'),
            radius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          _buildToggleOption(
            title: 'Năm',
            isSelected: _timeFilter == 'year',
            onTap: () => setState(() => _timeFilter = 'year'),
            radius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          _buildToggleOption(
            title: 'Chi phí', 
            isSelected: !_showIncome, 
            onTap: () => setState(() => _showIncome = false),
            radius: BorderRadius.circular(30),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          _buildToggleOption(
            title: 'Thu nhập', 
            isSelected: _showIncome, 
            onTap: () => setState(() => _showIncome = true),
            radius: BorderRadius.circular(30),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String title, 
    required bool isSelected, 
    required VoidCallback onTap,
    required BorderRadius radius,
    required EdgeInsets padding,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
          borderRadius: radius,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Map<String, double> _calculateCategoryData(List<Expense> expenses, {required bool isIncome}) {
    Map<String, double> data = {};
    for (var expense in expenses) {
      if ((isIncome && expense.type == 'income') || (!isIncome && expense.type == 'expense')) {
        data[expense.category] = (data[expense.category] ?? 0) + expense.amount;
      }
    }
    return data;
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> data) {
    final double total = data.values.fold(0, (sum, val) => sum + val);

    return data.entries.map((entry) {
      final isLarge = entry.value / total > 0.1;
      return PieChartSectionData(
        color: CategoryUtils.getColor(entry.key, isIncome: _showIncome),
        value: entry.value,
        title: isLarge ? '${(entry.value / total * 100).toStringAsFixed(0)}%' : '',
        radius: isLarge ? 60.0 : 50.0,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Expense> _filterExpenses(List<Expense> expenses, {required bool isIncome}) {
    return expenses.where((e) {
      if (isIncome) return e.type == 'income';
      return e.type == 'expense';
    }).toList();
  }

  Widget _buildStatRowWithDetails(String category, double totalAmount, List<Expense> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: CategoryUtils.getColor(category, isIncome: _showIncome).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CategoryUtils.getIcon(category, isIncome: _showIncome),
                      color: CategoryUtils.getColor(category, isIncome: _showIncome),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '${NumberFormat('#,###').format(totalAmount)} VNĐ',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.only(left: 48), // Indent under the icon
              child: Column(
                children: items.map((expense) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            expense.title,
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(expense.date),
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${NumberFormat('#,###').format(expense.amount)} VNĐ',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildTimeBarChart(List<Expense> expenses) {
    // 1. Nhóm dữ liệu theo time filter (day, month, year)
    Map<String, Map<String, double>> groupedData = {}; // key: timeLabel, value: { 'income': 0, 'expense': 0, 'balance': 0 }
    
    // Sort expenses chronologically
    final sortedExpenses = List<Expense>.from(expenses)..sort((a, b) => a.date.compareTo(b.date));

    // Lọc theo khoảng thời gian gần đây nhất để biểu đồ không quá dài
    // Giữ lại 7 ngày, 6 tháng, hoặc 5 năm gần nhất.
    List<Expense> filteredExpenses = sortedExpenses;

    for (var expense in filteredExpenses) {
      String label = '';
      if (_timeFilter == 'day') {
        label = DateFormat('dd/MM').format(expense.date);
      } else if (_timeFilter == 'month') {
        label = DateFormat('MM/yyyy').format(expense.date);
      } else {
        label = DateFormat('yyyy').format(expense.date);
      }

      if (!groupedData.containsKey(label)) {
        groupedData[label] = {'income': 0, 'expense': 0, 'balance': 0};
      }
      
      if (expense.type == 'income') {
        groupedData[label]!['income'] = groupedData[label]!['income']! + expense.amount;
      } else {
        groupedData[label]!['expense'] = groupedData[label]!['expense']! + expense.amount;
      }
    }

    if (groupedData.isEmpty) {
      return const Center(child: Text("Không có dữ liệu thời gian", style: TextStyle(color: Colors.white70)));
    }

    // Tính balance và lấy maxY, minY
    double maxY = 0;
    double minY = 0;
    
    for (var key in groupedData.keys) {
      final income = groupedData[key]!['income']!;
      final expense = groupedData[key]!['expense']!;
      final balance = income - expense;
      groupedData[key]!['balance'] = balance;

      if (income > maxY) maxY = income;
      if (expense > maxY) maxY = expense;
      if (balance > maxY) maxY = balance;
      if (balance < minY) minY = balance; // balance can be negative
    }
    
    // Thêm padding cho trục Y (tối đa 20%)
    if (maxY == 0) maxY = 100;
    maxY = maxY * 1.2;
    if (minY < 0) {
      minY = minY * 1.2;
    } else {
      minY = 0;
    }

    List<String> labels = groupedData.keys.toList();
    // Giữ lại tối đa 7 mốc thời gian gần nhất
    if (labels.length > 7) {
      labels = labels.sublist(labels.length - 7);
    }

    // Mã màu theo yêu cầu
    final Color incomeColor = Colors.blue; 
    final Color expenseColor = Colors.red;
    final Color balanceColor = Colors.lightGreen;

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < labels.length; i++) {
      String label = labels[i];
      final income = groupedData[label]!['income']!;
      final expense = groupedData[label]!['expense']!;
      final balance = groupedData[label]!['balance']!;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 4, // Khoảng cách giữa các cột trong 1 group
          barRods: [
            BarChartRodData(
              toY: income,
              color: incomeColor,
              width: 14,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              toY: expense,
              color: expenseColor,
              width: 14,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              toY: balance,
              color: balanceColor,
              width: 14,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Legend và Đơn vị
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
               padding: const EdgeInsets.only(left: 16.0),
               child: Text('Đơn vị: VNĐ', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontStyle: FontStyle.italic)),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendItem(incomeColor, 'Thu nhập'),
                  const SizedBox(height: 4),
                  _buildLegendItem(expenseColor, 'Chi phí'),
                  const SizedBox(height: 4),
                  _buildLegendItem(balanceColor, 'Chênh lệch'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Chart
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxY,
              minY: minY,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('Thời gian', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  axisNameSize: 24,
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < labels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            labels[value.toInt()],
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 42,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                       // Chỉ hiển thị các mốc chính, ẩn các giá trị quá lẻ
                       if (value == maxY || value == minY) return const SizedBox.shrink(); 
                       return Padding(
                         padding: const EdgeInsets.only(right: 8.0),
                         child: Text(
                           value.toInt().toString(),
                           style: const TextStyle(color: Colors.white70, fontSize: 10),
                           textAlign: TextAlign.right,
                         ),
                       );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true, // Show border để thấy rõ gốc toạ độ 0
                border: Border(
                   bottom: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
                   left: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
                   right: BorderSide.none,
                   top: BorderSide.none,
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4 == 0 ? 1 : maxY / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: value == 0 ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.1), // Đường gốc toạ độ 0 rõ hơn
                    strokeWidth: value == 0 ? 1.5 : 1,
                  );
                },
              ),
              barGroups: barGroups,
              alignment: BarChartAlignment.spaceAround,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
