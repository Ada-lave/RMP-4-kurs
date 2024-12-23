import 'dart:io';

import 'package:docfiy/components/dialog_menu.dart';
import 'package:docfiy/components/nav_bar_item.dart';
import 'package:docfiy/components/statistics/bar_statistic.dart';
import 'package:docfiy/db/database_base.dart';
import 'package:docfiy/db/models/statistic.dart';
import 'package:docfiy/db/postgres.dart';
import 'package:docfiy/db/sqlite.dart';
import 'package:docfiy/utils/files/doci_file_manager.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path/path.dart';
import 'components/nav_bar.dart';
import 'dart:io' show Platform;

List<NavBarItem> menu = [
  NavBarItem("Мои doc", "/doc_files", const Icon(Icons.document_scanner)),
  NavBarItem("Мои pdf", "/pdf_files", const Icon(Icons.picture_as_pdf)),
  NavBarItem("Статистика", "/statistics", const Icon(Icons.bar_chart))
];

void main() {
  runApp(const DocifyApp());
}

class DocifyApp extends StatelessWidget {
  const DocifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/doc_files",
      routes: {
        "/statistics": (context) => const StatisticScreen(),
        "/doc_files": (context) => FilesScreen(fileExt: "doc"),
        "/pdf_files": (context) => FilesScreen(fileExt: "pdf"),
      },
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Colors.blue,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blueAccent[200], iconSize: 30),
        drawerTheme: const DrawerThemeData(),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.blue[50],
          titleTextStyle: TextStyle(color: Colors.blue[900], fontSize: 20),
          contentTextStyle: TextStyle(color: Colors.blue[700], fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(Colors.blueAccent[200]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.blueAccent[200]),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            textStyle: WidgetStateProperty.all(TextStyle(fontSize: 16)),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FilesScreen extends StatefulWidget {
  final String fileExt; 
  FilesScreen({required this.fileExt, super.key});

  @override
  State<StatefulWidget> createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<FilesScreen> {
  final DociFileManager dociFileManager = DociFileManager();
  final DatabaseService db = getDatabase();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    dociFileManager.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Docify - Ваши документы"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: 'Поиск по названию файла',
                  prefixIcon: const Icon(Icons.search),
                  hintStyle: const TextStyle(color: Colors.white),
                  focusColor: Colors.blue,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  )),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
        ),
      ),
      drawer: NavBar(items: menu),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return FormDialog(
                  db: db,
                );
              });
          dociFileManager.updateFileStream();
        },
        child: const Icon(Icons.edit_document),
      ),
      body: StreamBuilder<List<File>>(
          stream: dociFileManager.fileStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              print("Файлов нету");
              return const Center(
                child: Text(
                  "История ваших файлов пуста.",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            final files = snapshot.data!.where((file) {
              final fileName = basename(file.path)
                  .toLowerCase()
                  .contains((_searchQuery.toLowerCase()));
              return fileName && file.path.split(Platform.pathSeparator).last.contains(widget.fileExt);
            }).toList();

            if (files.isEmpty) {
              return const Center(
                child: Text(
                  "Файлы не найдены.",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.separated(
              itemBuilder: (context, index) {
                final file = files[index];
                return FutureBuilder<FileStat>(
                  future: file.stat(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return ListTile(
                        title: Text(file.path.split("/").last),
                        subtitle: const Text("Получение данных..."),
                        leading: const Icon(Icons.file_present),
                      );
                    }

                    final fileStat = snapshot.data!;
                    final sizeInKB = (fileStat.size / 1024)
                        .toStringAsFixed(2); // Размер в КБ
                    return ListTile(
                      title: Text(basename(file.path)),
                      subtitle: Text("Размер: $sizeInKB КБ"),
                      leading: const Icon(Icons.file_present),
                      trailing: IconButton(
                        onPressed: () => dociFileManager.deleteFile(file),
                        icon: const Icon(Icons.delete),
                      ),
                      onTap: () async {
                        try {
                          final result = await OpenFile.open(file.path);

                          if (result.type != ResultType.done) {
                            debugPrint(
                                'Ошибка при открытии файла: ${result.message}');
                          }
                        } catch (e) {
                          debugPrint('Ошибка: $e');
                        }
                      },
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: files.length,
            );
          }),
    );
  }
}

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  _StatisticScreenState createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  final DatabaseService db = getDatabase();
  late Future<List<Statistic>?> data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = db.selectAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Docify - Статистика"),
      ),
      drawer: NavBar(items: menu),
      body: FutureBuilder(
          future: data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Ошибка загрузки данных"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Данных пока нет"));
            } else {
              var groupedData = groupStatisticsByDay(snapshot.data!);
              int lenght = snapshot.data!.length;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 450,
                      ),
                      child: BarStatistic(data: groupedData),
                    ),
                  ),
                  ListTile(title: Text("Общее количество: $lenght")),
                ],
              );
            }
          }),
    );
  }
}

DatabaseService getDatabase() {
  if (Platform.isAndroid) {
    return SqliteDatabase();
  } else {
    final db = PostgreDatabase("localhost", 5432, "pg", "pg", "statistic");
    db.init();
    return db;
  }
}
