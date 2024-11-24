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
import 'components/nav_bar.dart';
import 'dart:io' show Platform;

List<NavBarItem> menu = [
  NavBarItem("Мои файлы", "/files", Icon(Icons.upload_file)),
  NavBarItem("Статистика", "/statistics", Icon(Icons.bar_chart))
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
        "/statistics": (context) => StatisticScreen(),
        "/files": (context) => FilesScreen()
      },
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
            color: Colors.blue,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.blueAccent[200], iconSize: 30),
          drawerTheme: DrawerThemeData()),
    );
  }
}

class FilesScreen extends StatefulWidget {
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
          print(await db.insert(Statistic(
              fileSize: 1232,
              startAt: DateTime.now().toString(),
              endAt: DateTime.now().toString())));
          // uploadFile(context, dociFileManager);
        },
        child: const Icon(Icons.edit_document),
      ),
      body: StreamBuilder<List<File>>(
          stream: dociFileManager.fileStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              print("Файлов нету");
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              );
            }

            final files = snapshot.data!;

            return ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(files[index].path.split("/").last),
                    subtitle: Text("Размер 156КБ"),
                    subtitleTextStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    leading: Icon(Icons.file_present),
                    trailing: IconButton(
                      onPressed: () => dociFileManager.deleteFile(files[index]),
                      icon: Icon(Icons.delete),
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: files.length);
          }),
    );
  }
}

class StatisticScreen extends StatefulWidget {
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
          title: const Text("Docify - Ваши документы"),
        ),
        drawer: NavBar(items: menu),
        body: FutureBuilder(
            future: data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Ошибка загрузки данных"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("Данных пока нет"));
              } else {
                var groupedData = groupStatisticsByDay(snapshot.data!);
                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 300,
                    ),
                    child: BarStatistic(data: groupedData),
                  ),
                );
              }
            }));
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
