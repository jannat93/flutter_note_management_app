import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note_model.dart';

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
            (doc) => NoteModel.fromMap(
          doc.id,
          doc.data()
          as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }

  Future<void> addNote(
      NoteModel note,
      ) async {
    await notes.add(note.toMap());
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
  }
}