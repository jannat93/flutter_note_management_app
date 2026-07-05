import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../drawer/app_drawer.dart';
import '../models/note_model.dart';
import '../services/firestore_service.dart';
import '../widgets/note_card.dart';
import 'add_edit_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final FirestoreService firestoreService =
  FirestoreService();

  String search = '';
  String sortBy = 'date';
  String selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        onFilterSelected: (value) {
          setState(() {
            selectedFilter = value;
          });
        },
      ),

      appBar: AppBar(
        title: const Text(
          'Notes Manager',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'sortDate':
                  setState(() {
                    sortBy = 'date';
                  });
                  break;

                case 'sortTitle':
                  setState(() {
                    sortBy = 'title';
                  });
                  break;

                case 'share':
                  Share.share(
                    'Check out my Notes Manager App 🚀',
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sortDate',
                child: Text('Sort By Date'),
              ),
              const PopupMenuItem(
                value: 'sortTitle',
                child: Text('Sort By Title'),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Text('Share App'),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon:
                const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<List<NoteModel>>(
              stream:
              firestoreService.getNotes(),
              builder:
                  (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                List<NoteModel> notes =
                snapshot.data!;

                /// SEARCH + FILTER
                notes = notes.where((note) {
                  bool matchesSearch =
                      note.title
                          .toLowerCase()
                          .contains(
                        search
                            .toLowerCase(),
                      ) ||
                          note.description
                              .toLowerCase()
                              .contains(
                            search
                                .toLowerCase(),
                          );

                  if (!matchesSearch) {
                    return false;
                  }

                  switch (selectedFilter) {
                    case 'favorite':
                      return note.isFavorite;

                    case 'recent':
                      return true;

                    case 'pending':
                      return note.status ==
                          'Pending';

                    case 'completed':
                      return note.status ==
                          'Completed';

                    case 'overdue':
                      return note.dueDate
                          .toDate()
                          .isBefore(
                        DateTime.now(),
                      ) &&
                          note.status !=
                              'Completed';

                    default:
                      return true;
                  }
                }).toList();

                /// SORTING
                if (selectedFilter ==
                    'recent') {
                  notes.sort(
                        (a, b) => b.createdAt
                        .toDate()
                        .compareTo(
                      a.createdAt
                          .toDate(),
                    ),
                  );
                } else if (sortBy ==
                    'title') {
                  notes.sort(
                        (a, b) =>
                        a.title.compareTo(
                          b.title,
                        ),
                  );
                } else {
                  notes.sort(
                        (a, b) => b.createdAt
                        .toDate()
                        .compareTo(
                      a.createdAt
                          .toDate(),
                    ),
                  );
                }

                if (notes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Notes Found',
                    ),
                  );
                }

                int completed =
                    notes
                        .where(
                          (e) =>
                      e.status ==
                          "Completed",
                    )
                        .length;

                double progress =
                notes.isEmpty
                    ? 0
                    : completed /
                    notes.length;

                return Column(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 16,
                      ),
                      child: Card(
                        child: Padding(
                          padding:
                          const EdgeInsets
                              .all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  const Text(
                                    'Task Progress',
                                    style:
                                    TextStyle(
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                  Text(
                                    '$completed/${notes.length}',
                                  ),
                                ],
                              ),

                              const SizedBox(
                                  height: 10),

                              LinearProgressIndicator(
                                value: progress,
                                minHeight: 10,
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child:
                      ListView.builder(
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

                            onDelete: () async {
                              await firestoreService
                                  .deleteNote(
                                note.id,
                              );
                            },

                            onFavorite:
                                () async {
                              await firestoreService
                                  .toggleFavorite(
                                note,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const AddEditNoteScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'New Note',
        ),
      ),
    );
  }
}