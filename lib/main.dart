import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/notes_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:
    DefaultFirebaseOptions
        .currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp
    extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
      false,
      title:
      'Notes Management App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed:
        Colors.deepPurple,
      ),
      home: const NotesScreen(),
    );
  }
}