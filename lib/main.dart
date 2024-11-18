import 'dart:io';

import 'package:docfiy/utils/files/doci_file_manager.dart';
import 'package:docfiy/utils/files/upload_file.dart';
import 'package:flutter/material.dart';
import 'components/nav_bar.dart';

void main() {
  runApp(const DocifyApp());
}

class DocifyApp extends StatelessWidget {
  const DocifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (context) => SecondScreen(),
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
      drawer: NavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          uploadFile(context, dociFileManager);
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

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Docify - Ваши документы"),
        ),
        drawer: NavBar(),
        body: Center(
          child: ElevatedButton(
            child: const Text('Open route'),
            onPressed: () {
              // Navigate to second route when tapped.
            },
          ),
        ));
  }
}
