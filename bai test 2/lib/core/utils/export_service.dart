import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import '../../features/expense/domain/entities/expense.dart';
import 'file_saver/file_saver.dart';

class ExportService {
  static Future<void> exportExpensesToCSV(List<Expense> expenses) async {
    try {
      // 1. Khởi tạo Header
      List<List<dynamic>> rows = [
        ['ID', 'Tiêu đề', 'Số tiền', 'Loại', 'Danh mục', 'Ngày giao dịch']
      ];

      // 2. Map dữ liệu vào Row
      for (var expense in expenses) {
        rows.add([
          expense.id,
          expense.title,
          expense.amount,
          expense.type == 'income' ? 'Thu nhập' : 'Chi phí',
          expense.category,
          DateFormat('yyyy-MM-dd HH:mm').format(expense.date),
        ]);
      }

      // 3. Chuyển thành chuỗi CSV (dùng thư viện csv 7.x)
      const encoder = CsvEncoder();
      String csvData = encoder.convert(rows);

      // 4. Sử dụng FileSaver để lưu và chia sẻ tuỳ theo nền tảng (Web/Mobile)
      final fileName = 'Expense_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
      await getFileSaver().saveAndShare(csvData, fileName);

    } catch (e) {
      print("Lỗi khi Export file CSV: $e");
    }
  }
}
