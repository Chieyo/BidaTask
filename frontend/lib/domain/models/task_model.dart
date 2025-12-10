import 'package:google_maps_flutter/google_maps_flutter.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final double price;
  final DateTime postedTime;
  final DateTime? dueDate;
  final String location;
  final String postedBy;
  final String? imageUrl;
  final String category;
  final bool isMyTask;
  final bool isUrgent;
  final bool isTaken; // New field to track if task is taken
  final String? assigneeName; // Name of the person who took the task
  final String? assigneeAvatar; // Avatar of the person who took the task
  final String taskStatus; // Status of the task: todo, pending_completion, completed

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.postedTime,
    this.dueDate,
    required this.location,
    required this.postedBy,
    this.imageUrl,
    required this.category,
    required this.isMyTask,
    required this.isUrgent,
    required this.isTaken,
    this.assigneeName,
    this.assigneeAvatar,
    required this.taskStatus,
  });

  // Helper method to calculate time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(postedTime);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Helper method to format price
String get formattedPrice => '₱${price.toStringAsFixed(0)}';
  // Helper method to calculate distance (you'll implement the actual calculation later)
  String getDistanceFrom(LatLng userLocation) {
    // This is a placeholder - you'll implement actual distance calculation
    // using the haversine formula or a geolocation package
    final distanceInKm = 1.5; // Example distance
    return '${distanceInKm.toStringAsFixed(1)} km away';
  }

  factory Task.fromJson(Map<String, dynamic> json, {bool isMineOverride = false}) {
    // Debug logging
    print('Task JSON: ${json['id']} - assignee_id: ${json['assignee_id']}, assigneeId: ${json['assigneeId']}');
    
    final price = double.tryParse(json['reward']?.toString() ?? json['price']?.toString() ?? '0') ?? 0;
    final category = json['category'] ?? json['task_category'] ?? 'General';
    final dueDate = json['dueDate'] != null 
        ? DateTime.tryParse(json['dueDate'])
        : (json['due_date'] != null 
            ? DateTime.tryParse(json['due_date'])
            : null);
    final postedTime = json['postedTime'] != null
        ? DateTime.tryParse(json['postedTime'])
        : (json['created_at'] != null 
            ? DateTime.tryParse(json['created_at'])
            : DateTime.now());
    final priority = json['priority'] ?? json['task_priority'] ?? 'normal';
    final requesterName = json['requesterName'] ?? 'Task Owner';

    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? json['task_title'] ?? 'Untitled Task',
      description: json['description'] ?? json['task_description'] ?? 'No description provided.',
      price: price,
      postedTime: postedTime ?? DateTime.now(),
      dueDate: dueDate,
      location: json['location'] ?? json['locationName'] ?? json['location_name'] ?? 'No location specified',
      postedBy: requesterName,
      category: category,
      isMyTask: isMineOverride || (json['isMine'] == true),
      isUrgent: priority == 'high',
      isTaken: json['assignee_id'] != null || json['assigneeId'] != null,
      assigneeName: json['assigneeName'],
      assigneeAvatar: json['assigneeAvatar'],
      taskStatus: json['task_status']?.toString() ?? json['status']?.toString() ?? 'todo',
    );
  }

  // Helper property to check if task is completed
  bool get isCompleted => taskStatus == 'completed';

  // Helper property to check if task is pending completion
  bool get isPendingCompletion => taskStatus == 'pending_completion';
}
