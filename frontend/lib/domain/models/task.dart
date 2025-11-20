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
    String? id,
    String? title,
    String? author,
    DateTime? dueDate,
    TaskStatus? status,
    bool? isPostedByMe,
    String? assignedTo,
    String? description,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      isPostedByMe: isPostedByMe ?? this.isPostedByMe,
      assignedTo: assignedTo ?? this.assignedTo,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && 
           other.id == id &&
           other.title == title &&
           other.author == author &&
           other.dueDate == dueDate &&
           other.status == status &&
           other.isPostedByMe == isPostedByMe &&
           other.assignedTo == assignedTo &&
           other.description == description &&
           other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        author,
        dueDate,
        status,
        isPostedByMe,
        assignedTo,
        description,
        createdAt,
      );
}
