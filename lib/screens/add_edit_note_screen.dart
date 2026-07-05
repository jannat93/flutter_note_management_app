import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../services/firestore_service.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;

  const AddEditNoteScreen({
    super.key,
    this.note,
  });

  @override
  State<AddEditNoteScreen> createState() =>
      _AddEditNoteScreenState();
}

class _AddEditNoteScreenState
    extends State<AddEditNoteScreen> {
  final titleController =
  TextEditingController();

  final descriptionController =
  TextEditingController();

  String status = 'Pending';

  final firestoreService =
  FirestoreService();

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      titleController.text =
          widget.note!.title;

      descriptionController.text =
          widget.note!.description;

      status = widget.note!.status;
    }
  }

  Future<void> saveNote() async {
    if (titleController.text
        .trim()
        .isEmpty) {
      return;
    }

    if (widget.note == null) {
      final note = NoteModel(
        id: '',
        title:
        titleController.text.trim(),
        description:
        descriptionController.text
            .trim(),
        isFavorite: false,
        status: status,
        createdAt: Timestamp.now(),
      );

      await firestoreService.addNote(
        note,
      );
    } else {
      final updated = NoteModel(
        id: widget.note!.id,
        title:
        titleController.text.trim(),
        description:
        descriptionController.text
            .trim(),
        isFavorite:
        widget.note!.isFavorite,
        status: status,
        createdAt:
        widget.note!.createdAt,
      );

      await firestoreService
          .updateNote(updated);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null
              ? 'Add Note'
              : 'Edit Note',
        ),
      ),
      body: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller:
              titleController,
              decoration:
              const InputDecoration(
                labelText: 'Title',
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
              descriptionController,
              maxLines: 5,
              decoration:
              const InputDecoration(
                labelText:
                'Description',
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField(
              value: status,
              items: const [
                DropdownMenuItem(
                  value: 'Pending',
                  child:
                  Text('Pending'),
                ),
                DropdownMenuItem(
                  value: 'Completed',
                  child:
                  Text('Completed'),
                ),
                DropdownMenuItem(
                  value: 'Overdue',
                  child:
                  Text('Overdue'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  status =
                      value.toString();
                });
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveNote,
                child: const Text(
                  'Save Note',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}