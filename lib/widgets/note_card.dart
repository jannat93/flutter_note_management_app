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

    // Derive a soft gradient + accent from the existing color logic
    // without changing any of the underlying rules above.
    final Color gradientStart = Color.alphaBlend(
      Colors.white.withOpacity(0.55),
      cardColor,
    );
    final Color gradientEnd = cardColor;

    final progressValue = note.status == "Completed"
        ? 1.0
        : dueDate.isBefore(now)
        ? 0.0
        : 0.5;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gradientStart, gradientEnd],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Title row ----
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _CircleIconButton(
                      icon: note.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      iconColor: Colors.amber.shade700,
                      onPressed: onFavorite,
                    ),
                    const SizedBox(width: 4),
                    _CircleIconButton(
                      icon: Icons.more_vert_rounded,
                      iconColor: Colors.black54,
                      onPressed: null,
                      popupItems: const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 18, color: Colors.redAccent),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit();
                        }
                        if (value == 'delete') {
                          onDelete();
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // ---- Description ----
                Text(
                  note.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Colors.black.withOpacity(0.65),
                  ),
                ),

                const SizedBox(height: 14),

                // ---- Dates ----
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    _DateChip(
                      icon: Icons.schedule_rounded,
                      label:
                      "Created ${DateFormat('dd MMM yyyy').format(note.createdAt.toDate())}",
                    ),
                    _DateChip(
                      icon: Icons.event_rounded,
                      label:
                      "Due ${DateFormat('dd MMM yyyy').format(dueDate)}",
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ---- Status + remaining ----
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        note.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          remainingText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ---- Progress bar ----
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 7,
                    backgroundColor: Colors.white.withOpacity(0.55),
                    valueColor:
                    AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small reusable circular icon button used for the favorite star and
/// the overflow menu. Purely presentational — behavior is unchanged.
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onPressed;
  final List<PopupMenuEntry<String>>? popupItems;
  final ValueChanged<String>? onSelected;

  const _CircleIconButton({
    required this.icon,
    required this.iconColor,
    this.onPressed,
    this.popupItems,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final decoratedIcon = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );

    if (popupItems != null) {
      return PopupMenuButton<String>(
        itemBuilder: (_) => popupItems!,
        onSelected: onSelected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: decoratedIcon,
      );
    }

    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: decoratedIcon,
    );
  }
}

/// Small pill showing a date with an icon.
class _DateChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DateChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.black54),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}