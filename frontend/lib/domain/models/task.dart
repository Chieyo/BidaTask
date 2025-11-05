import 'package:flutter/foundation.dart';
import '../enums/task_status.dart';

class Task {
  final String id;
  final String title;
  final String author;
  final DateTime dueDate;
  TaskStatus status;
  final bool isPostedByMe;
  final String? assignedTo;
  final DateTime createdAt;
  final String? description;

  Task({
    required this.id,
    required this.title,
    required this.author,
    required this.dueDate,
    this.status = TaskStatus.notStarted,
    this.isPostedByMe = false,
    this.assignedTo,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    String? assignedTo,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      author: author,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      isPostedByMe: isPostedByMe,
      assignedTo: assignedTo ?? this.assignedTo,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
