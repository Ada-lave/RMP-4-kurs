import 'dart:io';

import 'package:docfiy/components/nav_bar_item.dart';
import 'package:docfiy/components/statistics/bar_statistic.dart';
import 'package:docfiy/db/database_base.dart';
import 'package:docfiy/db/models/statistic.dart';
import 'package:docfiy/db/postgres.dart';
import 'package:docfiy/db/sqlite.dart';
import 'package:docfiy/utils/files/doci_file_manager.dart';
import 'package:docfiy/utils/files/upload_file.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/nav_bar.dart';
import 'dart:io' show Platform;

List<NavBarItem> menu = [
  NavBarItem("Мои файлы", "/files", const Icon(Icons.upload_file)),
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
      initialRoute: "/files",
      routes: {
        "/statistics": (context) => const StatisticScreen(),
        "/files": (context) => const FilesScreen()
      },
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
            color: Colors.blue,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.blueAccent[200], iconSize: 30),
          drawerTheme: const DrawerThemeData()),
    );
  }
}

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<FilesScreen> {
  final DociFileManager dociFileManager = DociFileManager();
  final DatabaseService db = getDatabase();

  @override
  void dispose() {
    dociFileManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Docify - Ваши документы"),
      ),
      drawer: NavBar(items: menu),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var startAt = DateTime.now();
          File? res = await uploadFile(context, dociFileManager);
          var endAt = DateTime.now();
          var stats = await res?.stat();
          db.insert(Statistic(fileSize: stats!.size, startAt: startAt.toString(), endAt: endAt.toString()));
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

            final files = snapshot.data!;

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
                    final sizeInKB = (fileStat.size / 1024).toStringAsFixed(2); // Размер в КБ
                    return ListTile(
                      title: Text(basename(file.path)),
                      subtitle: Text("Размер: $sizeInKB КБ"),
                      leading: const Icon(Icons.file_present),
                      trailing: IconButton(
                        onPressed: () => dociFileManager.deleteFile(file),
                        icon: const Icon(Icons.delete),
                      ),
                      onTap: () async {
                      if (await canLaunchUrl(files[index].uri)) {
                        await launchUrl(files[index].uri);
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
                        maxHeight: 300,
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
