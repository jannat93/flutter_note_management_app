import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;

  const NoteCard({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final dueDate = note.dueDate.toDate();
    final now = DateTime.now();

    Color cardColor;
    Color statusColor;

    String remainingText;

    if (note.status == "Completed") {
      cardColor = Colors.green.shade100;
      statusColor = Colors.green;

      remainingText = "Completed";
    } else if (dueDate.isBefore(now)) {
      cardColor = Colors.red.shade100;
      statusColor = Colors.red;

      final days =
          now.difference(dueDate).inDays;

      remainingText =
      "$days day(s) overdue";
    } else {
      cardColor = Colors.blue.shade100;
      statusColor = Colors.orange;

      final days =
          dueDate.difference(now).inDays;

      remainingText =
      "$days day(s) remaining";
    }

    return Card(
      color: cardColor,
      elevation: 5,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style:
                    const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: onFavorite,
                  icon: Icon(
                    note.isFavorite
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),

                PopupMenuButton(
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child:
                      Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child:
                      Text('Delete'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value ==
                        'edit') {
                      onEdit();
                    }

                    if (value ==
                        'delete') {
                      onDelete();
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              note.description,
              maxLines: 3,
              overflow:
              TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  "Created: ${DateFormat('dd MMM yyyy').format(note.createdAt.toDate())}",
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(
                  Icons.event,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  "Due: ${DateFormat('dd MMM yyyy').format(dueDate)}",
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration:
                  BoxDecoration(
                    color: statusColor,
                    borderRadius:
                    BorderRadius
                        .circular(
                        20),
                  ),
                  child: Text(
                    note.status,
                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration:
                    BoxDecoration(
                      color: Colors.black12,
                      borderRadius:
                      BorderRadius
                          .circular(
                          20),
                    ),
                    child: Text(
                      remainingText,
                      textAlign:
                      TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: note.status ==
                  "Completed"
                  ? 1
                  : dueDate
                  .isBefore(now)
                  ? 0
                  : 0.5,
              minHeight: 8,
              borderRadius:
              BorderRadius.circular(
                  10),
            ),
          ],
        ),
      ),
    );
  }
}