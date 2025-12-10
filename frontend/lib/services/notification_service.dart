import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../presentation/models/notification_model.dart';

class NotificationService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Get authentication token (public method)
  Future<String?> getToken() async {
    return _getToken();
  }

  // Get authentication token
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Fetch all notifications for the user
  Future<List<NotificationItem>> fetchNotifications() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final List<dynamic> notifications = data['data'] ?? [];
        return notifications
            .map((notificationJson) => _mapApiToNotification(notificationJson))
            .toList();
      }

      throw Exception(data['message'] ?? 'Failed to fetch notifications');
    } catch (e) {
      throw Exception('Unable to load notifications: $e');
    }
  }

  // Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return data['data']['unreadCount'] ?? 0;
      }

      throw Exception(data['message'] ?? 'Failed to fetch unread count');
    } catch (e) {
      throw Exception('Unable to load unread count: $e');
    }
  }

  // Mark a notification as read
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Notification marked as read',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to mark notification as read',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error marking notification as read: $e',
      };
    }
  }

  // Mark all notifications as read
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'All notifications marked as read',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to mark all notifications as read',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error marking all notifications as read: $e',
      };
    }
  }

  // Delete a notification
  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Notification deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete notification',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting notification: $e',
      };
    }
  }

  // Map API response to frontend notification model
  NotificationItem _mapApiToNotification(Map<String, dynamic> apiNotification) {
    // Convert API type to frontend NotificationType
    NotificationType type;
    switch (apiNotification['type']) {
      case 'task':
        type = NotificationType.task;
        break;
      case 'success':
        type = NotificationType.success;
        break;
      case 'warning':
        type = NotificationType.warning;
        break;
      case 'info':
      default:
        type = NotificationType.info;
        break;
    }

    // Calculate time ago from created_at
    final createdAt = DateTime.tryParse(apiNotification['created_at'] ?? '');
    final timeAgo = _calculateTimeAgo(createdAt ?? DateTime.now());

    return NotificationItem(
      id: apiNotification['id'] ?? '',
      title: apiNotification['title'] ?? 'Notification',
      message: apiNotification['message'] ?? '',
      timeAgo: timeAgo,
      isRead: apiNotification['is_read'] ?? false,
      type: type,
    );
  }

  // Calculate time ago string
  String _calculateTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inSeconds > 0) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }
}
