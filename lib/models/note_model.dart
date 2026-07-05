import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  String id;
  String title;
  String description;
  bool isFavorite;
  String status;
  Timestamp createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavorite,
    required this.status,
    required this.createdAt,
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
      createdAt:
      data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isFavorite': isFavorite,
      'status': status,
      'createdAt': createdAt,
    };
  }
}