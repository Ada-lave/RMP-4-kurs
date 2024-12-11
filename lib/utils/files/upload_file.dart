import 'dart:io';

import 'package:docfiy/utils/files/doci_file_manager.dart';
import 'package:docfiy/utils/snacks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

Future<File?> uploadFile(BuildContext context, DociFileManager doci) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    File file = File(result.files.single.path!);

    showSnackBar(context, "Файл отправлен", Colors.blue);

    try {
      var request = MultipartRequest(
          "POST", Uri.parse("http://localhost:8000/process-docx/"));
      request.files.add(await MultipartFile.fromPath("file", file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        showSnackBar(context, "Успешно", Colors.green);
        var fileData = await response.stream.toBytes();
        await doci.addByteFile(file.path.split("\\").last, fileData);
      } else {
        showSnackBar(context, "Ошибка сети", Colors.red);
      }
      return file;
    } catch (e) {
      showSnackBar(context, "Ошибка загрузки", Colors.red);
    }
  }

  return null;
}
