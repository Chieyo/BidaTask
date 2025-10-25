import 'package:google_maps_flutter/google_maps_flutter.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final double price;
  final DateTime postedTime;
  final LatLng location;
  final String postedBy;
  final String? imageUrl;
  final String category;
  final bool isMyTask;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.postedTime,
    required this.location,
    required this.postedBy,
    this.imageUrl,
    required this.category,
    this.isMyTask = false,
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
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  // Helper method to calculate distance (you'll implement the actual calculation later)
  String getDistanceFrom(LatLng userLocation) {
    // This is a placeholder - you'll implement actual distance calculation
    // using the haversine formula or a geolocation package
    final distanceInKm = 1.5; // Example distance
    return '${distanceInKm.toStringAsFixed(1)} km away';
  }
}
