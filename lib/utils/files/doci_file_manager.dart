import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class DociFileManager {
  final StreamController<List<File>> _fileController =
      StreamController<List<File>>.broadcast();
  List<File> _files = [];

  Stream<List<File>> get fileStream => _fileController.stream;

  DociFileManager() {
    _loadFiles();
  }

  Future<String> _getDirPath() async {
    final dir = await getApplicationDocumentsDirectory();

    return dir.path;
  }

  Future<void> _loadFiles() async {
    final path = await _getDirPath();
    final dir = Directory(path);
    _files = dir.listSync().whereType<File>().where((file) {
      final extension = file.path.split('.').last.toLowerCase();
      return extension == 'docx' || extension == 'doc';
    }).toList();
    _fileController.add(_files);
  }

  Future<void> addFile(String fileName, String content) async {
    final path = await _getDirPath();
    final file = File('$path/$fileName');

    file.writeAsString(content);

    _files.add(file);
    _fileController.add(_files);
  }

  void dispose() {
    _fileController.close();
  }

  Future<void> deleteFile(File file) async {
    await file.delete();
    _loadFiles();
  }

  Future<void> addByteFile(String fileName, Uint8List content) async{
    final path = await _getDirPath();
    final file = File('$path/$fileName');

    file.writeAsBytes(content);

    _files.add(file);
    _fileController.add(_files);
  }
}
