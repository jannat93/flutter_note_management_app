import 'package:flutter/material.dart';

import '../screens/about_screen.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  final Function(String) onFilterSelected;

  const AppDrawer({
    super.key,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple,
                  Colors.purple,
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Icon(
                    Icons.note_alt,
                    size: 35,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Notes Manager",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                Text(
                  "Manage your tasks easily",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          _drawerTile(
            context,
            Icons.notes,
            "All Notes",
            "all",
          ),

          _drawerTile(
            context,
            Icons.star,
            "Favorites",
            "favorite",
          ),

          _drawerTile(
            context,
            Icons.history,
            "Recent Notes",
            "recent",
          ),

          _drawerTile(
            context,
            Icons.pending_actions,
            "Pending",
            "pending",
          ),

          _drawerTile(
            context,
            Icons.check_circle,
            "Completed",
            "completed",
          ),

          _drawerTile(
            context,
            Icons.warning,
            "Overdue",
            "overdue",
          ),

          const Divider(),

          ListTile(
            leading:
            const Icon(Icons.settings),
            title:
            const Text("Settings"),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const SettingsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(
      BuildContext context,
      IconData icon,
      String title,
      String filter,
      ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onFilterSelected(filter);
      },
    );
  }
}