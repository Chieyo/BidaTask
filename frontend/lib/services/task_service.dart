// task_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart' as latlng;
import '../domain/models/task_model.dart';

class TaskService {
  static final String baseUrl =
      (dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api').replaceFirst(RegExp(r'/$'), '');

  // Get authentication token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Create a new task
  Future<Map<String, dynamic>> createTask({
    required String title,
    required String description,
    required double reward,
    required String category,
    required String priority,
    required DateTime dueDate,
    required latlng.LatLng location,
    required String locationName,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'reward': reward,
          'category': category,
          'priority': priority,
          'dueDate': dueDate.toIso8601String(),
          'location': {
            'type': 'Point',
            'coordinates': [location.longitude, location.latitude],
          },
          'locationName': locationName,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body)['data'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to create task',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<List<Task>> fetchNearbyTasks({String? category}) async {
    try {
      final uri = Uri.parse('$baseUrl/tasks').replace(queryParameters: {
        if (category != null && category.isNotEmpty) 'category': category,
      });

      print('Fetching tasks from: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      final data = jsonDecode(response.body);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 && data['status'] == 'success') {
        final List<dynamic> tasks = data['data'] ?? [];
        print('Raw tasks count: ${tasks.length}');
        final mappedTasks = tasks
            .map((taskJson) => _mapTaskFromJson(taskJson))
            .whereType<Task>()
            .toList();
        print('Mapped tasks count: ${mappedTasks.length}');
        return mappedTasks;
      }

      throw Exception(data['message'] ?? 'Failed to fetch tasks');
    } catch (e) {
      print('Error in fetchNearbyTasks: $e');
      throw Exception('Unable to load tasks: $e');
    }
  }

  Future<List<Task>> fetchMyTasks() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication required');
    }

    try {
      final uri = Uri.parse('$baseUrl/tasks/mine');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final List<dynamic> tasks = data['data'] ?? [];
        return tasks
            .map((taskJson) => _mapTaskFromJson(taskJson, isMineOverride: true))
            .whereType<Task>()
            .toList();
      }

      throw Exception(data['message'] ?? 'Failed to fetch your tasks');
    } catch (e) {
      throw Exception('Unable to load your tasks: $e');
    }
  }

  Task? _mapTaskFromJson(Map<String, dynamic>? json, {bool isMineOverride = false}) {
    if (json == null) return null;

    final price = _toDouble(json['reward']);
    final postedTime = DateTime.tryParse('${json['createdAt'] ?? json['created_at']}') ?? DateTime.now();
    final dueDateRaw = json['dueDate'];
    final dueDate = dueDateRaw != null ? DateTime.tryParse('$dueDateRaw') : null;
    final category = (json['category'] ?? json['task_category'] ?? 'Misc').toString();
    final priority = (json['priority'] ?? json['task_priority'] ?? '').toString().toLowerCase();
    final requesterName = json['requesterName'] ?? 'Task Owner';

    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? json['task_title'] ?? 'Untitled Task',
      description: json['description'] ?? json['task_description'] ?? 'No description provided.',
      price: price,
      postedTime: postedTime,
      dueDate: dueDate,
      location: json['location'] ?? json['locationName'] ?? json['location_name'] ?? 'No location specified',
      postedBy: requesterName,
      category: category,
      isMyTask: isMineOverride || (json['isMine'] == true),
      isUrgent: priority == 'high',
    );
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}