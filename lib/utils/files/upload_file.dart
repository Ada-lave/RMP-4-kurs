import 'dart:io';

import 'package:docfiy/utils/snacks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<void> uploadFile(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    File file = File(result.files.single.path!);

    showSnackBar(context, "Файл добавлен");
  }
}
