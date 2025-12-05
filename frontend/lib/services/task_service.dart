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
            .map((taskJson) => Task.fromJson(taskJson))
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
            .map((taskJson) => Task.fromJson(taskJson))
            .whereType<Task>()
            .toList();
      }

      throw Exception(data['message'] ?? 'Failed to fetch your tasks');
    } catch (e) {
      throw Exception('Unable to load your tasks: $e');
    }
  }

  Future<List<Task>> fetchPostedTasks() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication required');
    }

    try {
      final uri = Uri.parse('$baseUrl/tasks/posted');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final List<dynamic> tasks = data['data'] ?? [];
        return tasks
            .map((taskJson) => Task.fromJson(taskJson, isMineOverride: true))
            .whereType<Task>()
            .toList();
      }

      throw Exception(data['message'] ?? 'Failed to fetch your posted tasks');
    } catch (e) {
      throw Exception('Unable to load your posted tasks: $e');
    }
  }

  
  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  // Accept/Take a task
  Future<Map<String, dynamic>> acceptTask(String taskId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tasks/$taskId/accept'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Task accepted successfully',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to accept task',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error accepting task: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteTask(String taskId) async {
    try {
      final token = await _getToken();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Task deleted successfully',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete task',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting task: $e',
      };
    }
  }

  Future<Map<String, dynamic>> markTaskAsDone(String taskId) async {
    try {
      final token = await _getToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/tasks/$taskId/complete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Task marked as done successfully',
        };
      } else if (response.statusCode == 429) {
        // Rate limit exceeded
        return {
          'success': false,
          'message': 'Too many requests. Please wait a moment and try again.',
        };
      } else {
        // Handle cases where response body might not be valid JSON
        String errorMessage = 'Failed to mark task as done';
        try {
          final data = json.decode(response.body);
          errorMessage = data['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error marking task as done: $e',
      };
    }
  }

  Future<Map<String, dynamic>> confirmTaskCompletion(String taskId) async {
    try {
      final token = await _getToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/tasks/$taskId/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Task completion confirmed successfully',
        };
      } else if (response.statusCode == 429) {
        // Rate limit exceeded
        return {
          'success': false,
          'message': 'Too many requests. Please wait a moment and try again.',
        };
      } else {
        // Handle cases where response body might not be valid JSON
        String errorMessage = 'Failed to confirm task completion';
        try {
          final data = json.decode(response.body);
          errorMessage = data['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error confirming task completion: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getCompletedTasks() async {
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/completed'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return {
            'success': true,
            'tasks': data['data'],
          };
        }
      } else if (response.statusCode == 429) {
        // Rate limit exceeded
        return {
          'success': false,
          'message': 'Too many requests. Please wait a moment and try again.',
        };
      } else {
        // Handle cases where response body might not be valid JSON
        String errorMessage = 'Failed to fetch completed tasks';
        try {
          final data = json.decode(response.body);
          errorMessage = data['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        
        return {
          'success': false,
          'message': errorMessage,
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to fetch completed tasks',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching completed tasks: $e',
      };
    }
  }
}