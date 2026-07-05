import 'package:flutter/material.dart';

class AboutScreen
    extends StatelessWidget {
  const AboutScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.note_alt,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Notes Management App',
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Built with Flutter & Firebase Firestore',
            ),
          ],
        ),
      ),
    );
  }
}