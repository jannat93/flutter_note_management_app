import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;

  const AddEditNoteScreen({
    super.key,
    this.note,
  });

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  double progressValue = 0.0;
  String status = "Pending";
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // How many minutes before the due time the reminder should fire.
  static const int reminderLeadMinutes = 2;

  final firestoreService = FirestoreService();

  // High-Contrast Accessible Color Palette
  final Color primaryBrandColor = const Color(0xFF1E3A8A); // Deep Navy Blue
  final Color textDarkColor = const Color(0xFF0F172A);     // High Visibility Slate Black
  final Color textMutedColor = const Color(0xFF475569);    // Medium Dark Gray for labels
  final Color fieldBorderColor = const Color(0xFF94A3B8);  // Defined Slate Gray for clear borders
  final Color surfaceBackgroundColor = const Color(0xFFFFFFFF); // Pure White Surface

  /// The actual due date + time combined into one DateTime.
  DateTime get dueDateTime => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      titleController.text = widget.note!.title;
      descriptionController.text = widget.note!.description;
      progressValue = (widget.note!.progress).toDouble().clamp(0.0, 100.0);
      status = widget.note!.status;

      final existingDueDate = widget.note!.dueDate.toDate();
      selectedDate = existingDueDate;
      selectedTime = TimeOfDay(
        hour: existingDueDate.hour,
        minute: existingDueDate.minute,
      );
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryBrandColor,
              primary: primaryBrandColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textDarkColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _syncStatusWithDueDateTime();
      });
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryBrandColor,
              primary: primaryBrandColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textDarkColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _syncStatusWithDueDateTime();
      });
    }
  }

  void _syncStatusWithDueDateTime() {
    if (dueDateTime.isBefore(DateTime.now()) && status != "Completed") {
      status = "Overdue";
    } else if (status == "Overdue" && dueDateTime.isAfter(DateTime.now())) {
      status = "Pending";
    }
  }

  Future<void> saveNote() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626), // Dark Red Error
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(
                  "Title cannot be empty",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
              ),
            ],
          ),
        ),
      );
      return;
    }

    final finalDueDateTime = dueDateTime;

    final note = NoteModel(
      id: widget.note?.id ?? "",
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      isFavorite: widget.note?.isFavorite ?? false,
      status: status,
      progress: progressValue.toInt(),
      createdAt: widget.note?.createdAt ?? Timestamp.now(),
      dueDate: Timestamp.fromDate(finalDueDateTime),
    );

    try {
      String noteId;

      if (widget.note == null) {
        noteId = await firestoreService.addNote(note);
        await NotificationService.showNotification(
          title: "New Note Added",
          body: "The note has been created successfully.",
        );
      } else {
        noteId = widget.note!.id;
        await firestoreService.updateNote(note);
        await NotificationService.showNotification(
          title: "Note Updated",
          body: "The note has been updated successfully.",
        );
      }

      // Reschedule the reminder any time the note is saved, since the
      // due date/time (or title) may have changed.
      final reminderId = NotificationService.idFromNoteId(noteId);
      await NotificationService.cancelReminder(reminderId);

      if (status != "Completed") {
        final reminderTime = finalDueDateTime
            .subtract(const Duration(minutes: reminderLeadMinutes));

        await NotificationService.scheduleReminder(
          id: reminderId,
          title: "Upcoming: ${note.title}",
          body: "Due in $reminderLeadMinutes minutes — ${note.title}",
          scheduledDate: reminderTime,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF065F46), // Deep Dark Green Success
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            content: const Text(
                "Saved Successfully",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text("Error: $e", style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    }
  }

  Color getStatusColor(String currentStatus) {
    switch (currentStatus) {
      case "Completed":
        return const Color(0xFF047857); // Dark Green
      case "Overdue":
        return const Color(0xFFB91C1C); // Dark Red
      default:
        return const Color(0xFFB45309); // Dark Amber/Orange
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.note != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light background for contrast
      appBar: AppBar(
        elevation: 1,
        backgroundColor: surfaceBackgroundColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textDarkColor, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode ? "Edit Note" : "Add New Note",
          style: TextStyle(
            color: textDarkColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content Frame
              Container(
                decoration: BoxDecoration(
                  color: surfaceBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: fieldBorderColor, width: 1),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Note Title",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDarkColor),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textDarkColor),
                      decoration: InputDecoration(
                        hintText: "Enter title here",
                        hintStyle: TextStyle(color: fieldBorderColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryBrandColor, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "Description",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDarkColor),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 5,
                      style: TextStyle(fontSize: 15, color: textDarkColor),
                      decoration: InputDecoration(
                        hintText: "Enter description details here",
                        hintStyle: TextStyle(color: fieldBorderColor),
                        contentPadding: const EdgeInsets.all(12),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryBrandColor, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Progress and Status Frame
              Container(
                decoration: BoxDecoration(
                  color: surfaceBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: fieldBorderColor, width: 1),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Task Progress",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDarkColor),
                        ),
                        Text(
                          "${progressValue.toInt()}%",
                          style: TextStyle(color: primaryBrandColor, fontWeight: FontWeight.bold, fontSize: 15),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 8,
                        activeTrackColor: primaryBrandColor,
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        thumbColor: primaryBrandColor,
                        valueIndicatorColor: primaryBrandColor,
                      ),
                      child: Slider(
                        value: progressValue,
                        min: 0.0,
                        max: 100.0,
                        onChanged: (value) {
                          setState(() {
                            progressValue = value;
                            if (progressValue >= 100.0) {
                              status = "Completed";
                            } else if (progressValue < 100.0 && status == "Completed") {
                              status = dueDateTime.isBefore(DateTime.now()) ? "Overdue" : "Pending";
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "Status Condition",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDarkColor),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: status,
                      dropdownColor: Colors.white,
                      style: TextStyle(color: textDarkColor, fontSize: 15, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: primaryBrandColor, width: 2),
                        ),
                      ),
                      items: ["Pending", "Completed", "Overdue"].map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(
                            val,
                            style: TextStyle(
                              color: getStatusColor(val),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          status = value!;
                          if (status == "Completed") {
                            progressValue = 100.0;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Date + Time Selection Panels
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: fieldBorderColor, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Due Date",
                                  style: TextStyle(color: textMutedColor, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Icon(Icons.calendar_today, size: 18, color: primaryBrandColor),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDarkColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: pickTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: fieldBorderColor, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Due Time",
                                  style: TextStyle(color: textMutedColor, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Icon(Icons.access_time, size: 18, color: primaryBrandColor),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatTime(selectedTime),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDarkColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, size: 16, color: primaryBrandColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "You'll get a reminder at ${_formatTime(
                          TimeOfDay.fromDateTime(
                            dueDateTime.subtract(
                              const Duration(minutes: reminderLeadMinutes),
                            ),
                          ),
                        )} — $reminderLeadMinutes minutes before this note is due.",
                        style: TextStyle(fontSize: 12, color: textMutedColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBrandColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                  ),
                  onPressed: saveNote,
                  child: Text(
                    isEditMode ? "Update Note Details" : "Save Note Entry",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}