class Task {
  final String id;
  final String title;
  final String description;
  final String category;
  final bool isUrgent;
  final String location;
  final List<String> imageUrls;
  final double reward;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int userTier;
  final DateTime dueDate;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isUrgent,
    required this.location,
    required this.imageUrls,
    required this.reward,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.userTier,
    required this.dueDate,
  });

  String get dueDateFormatted {
    final d = dueDate.toLocal();
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
