// lib/widgets/common/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:wm_jaya/utils/enums/menu_type.dart';

class AppDrawer extends StatelessWidget {
  final Function(MenuType) onMenuItemSelected;

  const AppDrawer({super.key, required this.onMenuItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
              child: Text(
                'Your App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: MenuType.values.map((menu) => ListTile(
                leading: Icon(menu.icon),
                title: Text(menu.label),
                onTap: () => onMenuItemSelected(menu),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}