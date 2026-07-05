import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.note_alt,
                  color: Colors.white,
                  size: 50,
                ),
                SizedBox(height: 10),
                Text(
                  'Notes Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading:
            const Icon(Icons.notes),
            title:
            const Text('All Notes'),
            onTap: () {},
          ),

          ListTile(
            leading:
            const Icon(Icons.star),
            title:
            const Text('Favorites'),
            onTap: () {},
          ),

          ListTile(
            leading:
            const Icon(Icons.history),
            title:
            const Text('Recent Notes'),
            onTap: () {},
          ),

          ListTile(
            leading:
            const Icon(Icons.warning),
            title:
            const Text('Overdue'),
            onTap: () {},
          ),

          ListTile(
            leading:
            const Icon(Icons.check),
            title:
            const Text('Finished'),
            onTap: () {},
          ),

          const Divider(),

          ListTile(
            leading:
            const Icon(Icons.settings),
            title:
            const Text('Settings'),
            onTap: () {},
          ),

          ListTile(
            leading:
            const Icon(Icons.info),
            title:
            const Text('About'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}