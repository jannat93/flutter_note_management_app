import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note_model.dart';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  CollectionReference get notes =>
      firestore.collection('notes');

  Stream<List<NoteModel>> getNotes() {
    return notes
        .orderBy(
      'createdAt',
      descending: true,
    )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) =>
            NoteModel.fromMap(
              doc.id,
              doc.data()
              as Map<String, dynamic>,
            ),
      )
          .toList(),
    );
  }

  /// Returns the new document's id, so the caller can immediately
  /// schedule a reminder notification tied to this note.
  Future<String> addNote(
      NoteModel note,
      ) async {
    final docRef = await notes.add(note.toMap());
    return docRef.id;
  }

  Future<void> updateNote(
      NoteModel note,
      ) async {
    await notes
        .doc(note.id)
        .update(note.toMap());
  }

  Future<void> deleteNote(
      String id,
      ) async {
    await notes.doc(id).delete();
    // Make sure a deleted note doesn't still fire a reminder later.
    await NotificationService.cancelReminder(
      NotificationService.idFromNoteId(id),
    );
  }

  Future<void> toggleFavorite(
      NoteModel note,
      ) async {
    await notes.doc(note.id).update({
      'isFavorite':
      !note.isFavorite,
    });
  }
}