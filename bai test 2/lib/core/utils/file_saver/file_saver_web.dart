import 'file_saver_base.dart';
import 'dart:html' as html;

class WebFileSaver implements FileSaver {
  @override
  Future<void> saveAndShare(String content, String fileName) async {
    // Thêm UTF-8 BOM để Excel hiển thị đúng tiếng Việt
    final blob = html.Blob(['\uFEFF', content], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}

FileSaver getFileSaver() => WebFileSaver();
