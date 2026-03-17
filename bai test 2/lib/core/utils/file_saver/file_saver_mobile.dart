import 'file_saver_base.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class MobileFileSaver implements FileSaver {
  @override
  Future<void> saveAndShare(String content, String fileName) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = '${dir.path}/$fileName';
    final File file = File(path);
    // Thêm UTF-8 BOM để Excel hiển thị đúng tiếng Việt
    await file.writeAsString('\uFEFF$content');
    await Share.shareXFiles([XFile(path)], text: 'Báo cáo chi tiêu cá nhân của bạn');
  }
}

FileSaver getFileSaver() => MobileFileSaver();
