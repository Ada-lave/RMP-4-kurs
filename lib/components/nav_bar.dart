import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text("Меню"),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            title: Text("Загрузка"),
            trailing: Icon(Icons.upload_file),
          ),
          Divider(),
          ListTile(
            title: Text("Мои файлы"),
            trailing: Icon(Icons.filter_drama_outlined),
          )
        ],
      ),
    );
  }
}
