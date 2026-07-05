import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../drawer/app_drawer.dart';
import '../models/note_model.dart';
import '../services/firestore_service.dart';
import '../widgets/note_card.dart';
import 'add_edit_note_screen.dart';

class NotesScreen
    extends StatefulWidget {
  const NotesScreen({
    super.key,
  });

  @override
  State<NotesScreen> createState() =>
      _NotesScreenState();
}

class _NotesScreenState
    extends State<NotesScreen> {
  final firestoreService =
  FirestoreService();

  String search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),

      appBar: AppBar(
        title: const Text(
          'Notes Manager',
        ),

        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'share') {
                Share.share(
                  'Check out my Notes App!',
                );
              }
            },
            itemBuilder:
                (context) => [
              const PopupMenuItem(
                value: 'sortDate',
                child: Text(
                  'Sort By Date',
                ),
              ),
              const PopupMenuItem(
                value:
                'sortTitle',
                child: Text(
                  'Sort By Title',
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Text(
                  'Share App',
                ),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.all(
              12,
            ),
            child: TextField(
              decoration:
              const InputDecoration(
                prefixIcon:
                Icon(Icons.search),
                hintText:
                'Search notes...',
              ),
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<
                List<NoteModel>>(
              stream: firestoreService
                  .getNotes(),
              builder:
                  (context, snapshot) {
                if (!snapshot
                    .hasData) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                var notes =
                snapshot.data!;

                notes = notes
                    .where(
                      (note) =>
                      note.title
                          .toLowerCase()
                          .contains(
                        search
                            .toLowerCase(),
                      ),
                )
                    .toList();

                if (notes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Notes Found',
                    ),
                  );
                }

                return ListView
                    .builder(
                  itemCount:
                  notes.length,
                  itemBuilder:
                      (context,
                      index) {
                    final note =
                    notes[index];

                    return NoteCard(
                      note: note,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                AddEditNoteScreen(
                                  note:
                                  note,
                                ),
                          ),
                        );
                      },
                      onDelete: () {
                        firestoreService
                            .deleteNote(
                          note.id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton:
      FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const AddEditNoteScreen(),
            ),
          );
        },
        child:
        const Icon(Icons.add),
      ),
    );
  }
}