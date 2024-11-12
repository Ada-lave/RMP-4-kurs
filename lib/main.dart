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
    // TODO: implement build
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (context) => MainScreen(),
        "/settings": (context) => const SecondScreen()
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

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final List<String> testDocs = [
    "Документ",
    "Документ",
    "Документ",
    "Документ",
    "Документ",
    "Документ",
    "Документ",
    "Документ",
    "Документ",
    "Документ",
    "Документ",
    "Документ",
    "Документ",
    "Документ",
    "Документ",
    "Документ",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Docify - Ваши документы"),
      ),
      drawer: NavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => uploadFile(context),
        child: const Icon(Icons.edit_document),
      ),
      body: Container(
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: testDocs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(testDocs[index]),
              subtitle: Text("Размер 156КБ"),
              subtitleTextStyle: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              leading: Icon(Icons.file_present),
              trailing: Icon(Icons.delete ),
            );
          },
        ),
      ),
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
