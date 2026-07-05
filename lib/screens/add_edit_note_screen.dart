import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../services/firestore_service.dart';

class AddEditNoteScreen
    extends StatefulWidget {
  final NoteModel? note;

  const AddEditNoteScreen({
    super.key,
    this.note,
  });

  @override
  State<AddEditNoteScreen>
  createState() =>
      _AddEditNoteScreenState();
}

class _AddEditNoteScreenState
    extends State<
        AddEditNoteScreen> {
  final titleController =
  TextEditingController();

  final descriptionController =
  TextEditingController();

  String status = "Pending";

  DateTime selectedDate =
  DateTime.now();

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

      status =
          widget.note!.status;

      selectedDate = widget
          .note!.dueDate
          .toDate();
    }
  }

  Future<void> pickDate() async {
    final picked =
    await showDatePicker(
      context: context,
      initialDate:
      selectedDate,
      firstDate:
      DateTime.now(),
      lastDate:
      DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate =
            picked;
      });
    }
  }

  Future<void> saveNote() async {
    if (titleController.text
        .trim()
        .isEmpty) {
      return;
    }

    final note = NoteModel(
      id: widget.note?.id ?? "",
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      isFavorite: widget.note?.isFavorite ?? false,
      status: status,
      progress: widget.note?.progress ?? 0,
      createdAt: widget.note?.createdAt ?? Timestamp.now(),
      dueDate: Timestamp.fromDate(selectedDate),
    );

    if (widget.note == null) {
      await firestoreService
          .addNote(note);
    } else {
      await firestoreService
          .updateNote(note);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null
              ? "Add Note"
              : "Edit Note",
        ),
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(
            16),
        child: Column(
          children: [
            TextField(
              controller:
              titleController,
              decoration:
              const InputDecoration(
                labelText:
                "Title",
              ),
            ),

            const SizedBox(
                height: 16),

            TextField(
              controller:
              descriptionController,
              maxLines: 5,
              decoration:
              const InputDecoration(
                labelText:
                "Description",
              ),
            ),

            const SizedBox(
                height: 16),

            DropdownButtonFormField(
              value: status,
              items: const [
                DropdownMenuItem(
                  value:
                  "Pending",
                  child: Text(
                      "Pending"),
                ),
                DropdownMenuItem(
                  value:
                  "Completed",
                  child: Text(
                      "Completed"),
                ),
                DropdownMenuItem(
                  value:
                  "Overdue",
                  child: Text(
                      "Overdue"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  status =
                      value.toString();
                });
              },
            ),

            const SizedBox(
                height: 20),

            Card(
              child: ListTile(
                leading:
                const Icon(
                  Icons
                      .calendar_month,
                ),
                title: Text(
                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                ),
                trailing:
                ElevatedButton(
                  onPressed:
                  pickDate,
                  child:
                  const Text(
                    "Select",
                  ),
                ),
              ),
            ),

            const SizedBox(
                height: 30),

            SizedBox(
              width:
              double.infinity,
              height: 55,
              child:
              ElevatedButton(
                onPressed:
                saveNote,
                child:
                const Text(
                  "Save Note",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}