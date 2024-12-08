import 'package:docfiy/components/nav_bar_item.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.items});

  final List<NavBarItem> items;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "Меню",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ...items
              .expand((item) => [
                    ListTile(
                        title: Text(item.name),
                        trailing: item.ico,
                        onTap: () => Navigator.pushNamed(context, item.route)),
                    const Divider()
                  ])
              
        ],
      ),
    );
  }
}
