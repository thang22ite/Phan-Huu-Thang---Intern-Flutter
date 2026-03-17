abstract class FileSaver {
  Future<void> saveAndShare(String content, String fileName);
}

FileSaver getFileSaver() => throw UnsupportedError('Cannot create a FileSaver without dart:html or dart:io');
