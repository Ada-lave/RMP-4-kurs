import 'dart:io';

import 'package:docfiy/db/database_base.dart';
import 'package:docfiy/db/models/statistic.dart';
import 'package:docfiy/utils/files/doci_file_manager.dart';
import 'package:docfiy/utils/files/upload_file.dart';
import 'package:flutter/material.dart';

class FormDialog extends StatefulWidget {
  final DatabaseService db;

  FormDialog({required this.db});

  @override
  _FormDialogState createState() => _FormDialogState();
}

class _FormDialogState extends State<FormDialog> {
  final DociFileManager dociFileManager = DociFileManager();
  bool formatBot = true;
  bool formatTop = false;
  bool convertToPdf = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Параметры'),
      content: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CheckboxListTile(
              title: Text('Отступы сверху'),
              value: formatTop,
              onChanged: (bool? value) {
                setState(() {
                  formatTop = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Отступы снизу'),
              value: formatBot,
              onChanged: (bool? value) {
                setState(() {
                  formatBot = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Конвертировать в PDF'),
              value: convertToPdf,
              onChanged: (bool? value) {
                setState(() {
                  convertToPdf = value!;
                });
              },
            ),
            Padding(padding: EdgeInsets.all(10)),
            ElevatedButton(
              onPressed: () async {
                var startAt = DateTime.now();
                File? res = await uploadFile(context, dociFileManager,
                    formatTop, formatBot, convertToPdf);

                if (res != null) {
                  var endAt = DateTime.now();
                  var stats = await res.stat();
                  widget.db.insert(Statistic(
                      fileSize: stats.size,
                      startAt: startAt.toString(),
                      endAt: endAt.toString()));
                }
                Navigator.pop(context);
              },
              child: Text('Выбрать файл'),
            ),
          ],
        ),
      ),
    );
  }
}
