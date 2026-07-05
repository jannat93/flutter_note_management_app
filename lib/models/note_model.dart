import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  String id;
  String title;
  String description;

  bool isFavorite;

  String status;

  int progress;

  Timestamp createdAt;

  Timestamp dueDate;

  NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavorite,
    required this.status,
    required this.progress,
    required this.createdAt,
    required this.dueDate,
  });

  factory NoteModel.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    return NoteModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isFavorite: data['isFavorite'] ?? false,
      status: data['status'] ?? 'Pending',
      progress: data['progress'] ?? 0,
      createdAt:
      data['createdAt'] ?? Timestamp.now(),
      dueDate:
      data['dueDate'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isFavorite': isFavorite,
      'status': status,
      'progress': progress,
      'createdAt': createdAt,
      'dueDate': dueDate,
    };
  }
}