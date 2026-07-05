import 'package:flutter/material.dart';

class NoteProvider extends ChangeNotifier {
  bool isGrid = false;

  void toggleView() {
    isGrid = !isGrid;
    notifyListeners();
  }
}