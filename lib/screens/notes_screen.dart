import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../drawer/app_drawer.dart';
import '../models/note_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../widgets/note_card.dart';
import 'add_edit_note_screen.dart';

// ---- Palette: warm ink & cream "notebook" theme ----
const Color _ink = Color(0xFF1F1B16);
const Color _cream = Color(0xFFFAF3E8);
const Color _amber = Color(0xFFE8A33D);
const Color _amberDeep = Color(0xFFC97C1F);
const Color _sage = Color(0xFF6B8F71);
const Color _clay = Color(0xFFC1573B);

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
      backgroundColor: _cream,
      drawer: AppDrawer(
        onFilterSelected: (value) {
          setState(() {
            selectedFilter = value;
          });
        },
      ),
      body: Builder(
        builder: (scaffoldContext) {
          return StreamBuilder<List<NoteModel>>(
            stream: firestoreService.getNotes(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: _amberDeep),
                );
              }

              List<NoteModel> notes = snapshot.data!;

              /// SEARCH + FILTER
              notes = notes.where((note) {
                bool matchesSearch = note.title
                    .toLowerCase()
                    .contains(search.toLowerCase()) ||
                    note.description
                        .toLowerCase()
                        .contains(search.toLowerCase());

                if (!matchesSearch) {
                  return false;
                }

                switch (selectedFilter) {
                  case 'favorite':
                    return note.isFavorite;

                  case 'recent':
                    return true;

                  case 'pending':
                    return note.status == 'Pending';

                  case 'completed':
                    return note.status == 'Completed';

                  case 'overdue':
                    return note.dueDate.toDate().isBefore(
                      DateTime.now(),
                    ) &&
                        note.status != 'Completed';

                  default:
                    return true;
                }
              }).toList();

              /// SORTING
              if (selectedFilter == 'recent') {
                notes.sort(
                      (a, b) => b.createdAt
                      .toDate()
                      .compareTo(a.createdAt.toDate()),
                );
              } else if (sortBy == 'title') {
                notes.sort(
                      (a, b) => a.title.compareTo(b.title),
                );
              } else {
                notes.sort(
                      (a, b) => b.createdAt
                      .toDate()
                      .compareTo(a.createdAt.toDate()),
                );
              }

              int completed =
                  notes.where((e) => e.status == "Completed").length;

              // Display-only derived stat, does not affect filtering/sorting.
              int overdue = notes
                  .where(
                    (e) =>
                e.status != "Completed" &&
                    e.dueDate.toDate().isBefore(DateTime.now()),
              )
                  .length;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: _ink,
                    expandedHeight: 108,
                    pinned: true,
                    elevation: 0,
                    leading: Builder(
                      builder: (ctx) => IconButton(
                        icon: const Icon(Icons.menu_rounded,
                            color: _cream),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                      ),
                    ),
                    actions: [
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz_rounded,
                            color: _cream),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'share',
                            child: Text('Share App'),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding:
                      const EdgeInsets.only(left: 20, bottom: 28),
                      title: const Text(
                        'Your Notes',
                        style: TextStyle(
                          color: _cream,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: _ink),
                          Positioned(
                            right: -30,
                            top: -20,
                            child: _decorRing(_amber.withOpacity(0.18), 140),
                          ),
                          Positioned(
                            right: 40,
                            top: 40,
                            child: _decorRing(_clay.withOpacity(0.16), 70),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating search pill overlapping the header
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, 26),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: _ink.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: TextField(
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Search your notes…',
                              hintStyle:
                              TextStyle(color: Colors.grey.shade500),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: _amberDeep,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                search = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Stat capsules row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 34, 20, 14),
                      child: SizedBox(
                        height: 74,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _statCapsule(
                              label: 'Total',
                              value: '${notes.length}',
                              color: _ink,
                              icon: Icons.dashboard_rounded,
                            ),
                            const SizedBox(width: 10),
                            _statCapsule(
                              label: 'Done',
                              value: '$completed',
                              color: _sage,
                              icon: Icons.check_circle_rounded,
                            ),
                            const SizedBox(width: 10),
                            _statCapsule(
                              label: 'Overdue',
                              value: '$overdue',
                              color: _clay,
                              icon: Icons.error_rounded,
                            ),
                            const SizedBox(width: 10),
                            _statCapsule(
                              label: 'Filter',
                              value: _filterLabel(selectedFilter),
                              color: _amberDeep,
                              icon: Icons.filter_alt_rounded,
                              wide: true,
                              onTap: () =>
                                  Scaffold.of(scaffoldContext).openDrawer(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (notes.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_cafe_rounded,
                              size: 56,
                              color: _ink.withOpacity(0.25),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Nothing here yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _ink.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Notes matching your search or\nfilter will show up here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: _ink.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 90),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final note = notes[index];

                            return NoteCard(
                              note: note,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditNoteScreen(
                                      note: note,
                                    ),
                                  ),
                                );
                              },
                              onDelete: () async {
                                await firestoreService.deleteNote(note.id);
                              },
                              onFavorite: () async {
                                await firestoreService.toggleFavorite(note);
                              },
                            );
                          },
                          childCount: notes.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditNoteScreen(),
            ),
          );
        },
        backgroundColor: _ink,
        foregroundColor: _amber,
        elevation: 3,
        icon: const Icon(Icons.edit_rounded),
        label: const Text(
          'New Note',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  String _filterLabel(String value) {
    switch (value) {
      case 'favorite':
        return 'Favorites';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'overdue':
        return 'Overdue';
      case 'recent':
        return 'Recent';
      default:
        return 'All';
    }
  }

  Widget _decorRing(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 14),
      ),
    );
  }

  Widget _statCapsule({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    bool wide = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: wide ? 118 : 88,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}